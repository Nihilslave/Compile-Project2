#include "IR.h"
#include "type.h"

using namespace Boost::Internal;
extern Type data_type;
extern std::map<std::string, size_t> indexlist;
extern std::map<std::string, std::vector<size_t> > varlist;
extern std::vector<std::string> ins;
extern std::vector<std::string> outs;
extern std::vector<std::string> grads;