#include "../include/IR.h"
#include "../include/type.h"
#include "../include/global.h"

using namespace Boost::Internal;
Type data_type = Boost::Internal::Type::float_scalar(32);
std::map<std::string, size_t> indexlist;
std::map<std::string, std::vector<size_t> > varlist;
std::vector<std::string> ins;
std::vector<std::string> outs;
std::vector<std::string> grads;