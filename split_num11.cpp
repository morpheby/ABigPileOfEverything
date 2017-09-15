/*
 Hi
 */


#include <iostream>
#include <utility>
#include <algorithm>
#include <vector>
#include <map>
#include <iterator>

struct Splitted {
    std::map<int, int> splits;

    int &operator[] (int num) {
        return splits[num];
    }

     int operator[] (int num) const {
         std::map<int,int>::const_iterator t = splits.find(num);
         if(t != splits.end())
             return t->second;
         else
             return 0;
    }
};

bool operator==(const Splitted &__lsv, const Splitted &__rsv) {
    return __lsv.splits.size() == __rsv.splits.size() &&
            std::equal(__lsv.splits.begin(), __lsv.splits.end(),
                       __rsv.splits.begin());
}

class Splitter {
protected:
    std::vector<Splitted> splits_;

public:
    virtual bool exists(const Splitted &check) const {
        return std::find(splits_.begin(), splits_.end(), check) != splits_.end();
    }

    void add(const Splitted &split) {
        splits_.push_back(split);
    }

    std::vector<Splitted> operator() (int num);
};

struct split_concatenator_worker {
    Splitted &target;

    split_concatenator_worker(Splitted &_target) :
        target(_target) {
    }

    void operator() (std::pair<int,int> p) {
        target[p.first] += p.second;
    }
};

struct split_concatenator {
    const Splitted &part;
    
    split_concatenator(const Splitted &_part) :
        part(_part) {

    }
    
    Splitted operator() (Splitted sp) {
        std::for_each(part.splits.begin(), part.splits.end(), split_concatenator_worker(sp));
        return sp;
    }
};

class SplitterNode : public Splitter {
    const Splitted part_;
    Splitter &parent_;

public:
    SplitterNode(const Splitted &part, Splitter &parent) :
        Splitter(),
        part_(part), parent_(parent) {
    }

    bool exists(const Splitted &check) const {
        std::vector<Splitted> t (splits_.size());
        return Splitter::exists(check) ||
                parent_.exists(split_concatenator(part_)(check));
    }
    
    std::vector<Splitted> operator() (int num) {
        splits_ = Splitter::operator()(num);
        
        std::vector<Splitted> result (splits_.size());
        std::transform(splits_.begin(), splits_.end(), result.begin(),
                              split_concatenator(part_));
        return std::move(result);
    }
};

std::vector<Splitted> Splitter::operator() (int num) {
    for (int i = 1; i < num; ++i) {
        Splitted t;
        ++t[i];
        std::vector<Splitted> res = SplitterNode(t, *this)(num - i);
        splits_.insert(splits_.end(), res.begin(), res.end());
    }
    
    Splitted t;
    ++t[num];
    if (!exists(t))
        add(t);

    return std::move(splits_);
}


struct _SplitValue{
    std::map<int,int>::value_type v;
    _SplitValue(std::map<int,int>::value_type __v) :
        v(__v) {}
};

template<class _CharT, class _Traits>
std::ostream &operator<< (std::basic_ostream<_CharT, _Traits> &str, _SplitValue p) {
    int count = p.v.second,
        i = p.v.first;
    std::fill_n(std::ostream_iterator<int>(str, " "), count, i);
    return str;
}

template<class _CharT, class _Traits>
std::ostream &operator<< (std::basic_ostream<_CharT, _Traits> &str, const Splitted &split) {
    std::copy(split.splits.begin(), split.splits.end(), std::ostream_iterator<_SplitValue>(str, " "));
    return str;
}

int main() {
    int num;
    std::cin >> num;

    std::vector<Splitted> result = Splitter()(num);
    std::copy(result.begin(), result.end(), std::ostream_iterator<Splitted>(std::cout, "\n"));

    return 0;
}
