
#include <cstdio>
#include <iostream>
#include <cstdlib>
#include <ctype.h>
#include <string.h>
#include <fstream>
#include <string>
#include <cstring>
#include <vector>
#include <map>
#include "../../3rdparty/jsoncpp/include/json/json.h"

#include "y.tab.h"
#include "../../include/IR.h"
#include "../../include/IRPrinter.h"
#include "../../include/IRMutator.h"
#include "../../include/global.h"
#include <typeinfo>
using namespace std;
using namespace Boost::Internal;

class MyMutator : public IRMutator {
 public:
    std::string grad_name;
    std::string out_name;
    Expr* grad_var;
    Expr* out_var;
    BinaryOpType binary_op = BinaryOpType::Or, binary_oop = BinaryOpType::Or;
    Expr visit(Ref<const IntImm> op) override {
        if (binary_op == BinaryOpType::Mul || binary_op == BinaryOpType::Div)
        {
            return op;
        }
        return Expr(0);
    }
    Expr visit(Ref<const UIntImm> op) override {
        if (binary_op == BinaryOpType::Mul || binary_op == BinaryOpType::Div)
        {
            return op;
        }
        return Expr(0);
    }
    Expr visit(Ref<const FloatImm> op) override {
        if (binary_op == BinaryOpType::Mul || binary_op == BinaryOpType::Div)
        {
            return op;
        }
        return Expr(0);
    }
    Stmt visit(Ref<const Move> op) override {
        mutate(op->dst);
        Expr new_src = mutate(op->src);
        Expr new_dst = Expr(grad_var->real_ptr());
        return Move::make(new_dst, new_src, op->move_type);
    }
    Expr visit(Ref<const Binary> op) override {
        binary_oop = binary_op;
        binary_op = op->op_type;
        //std::cout<<(int)binary_op<<endl;
        Expr new_a = mutate(op->a);
        Expr new_b = mutate(op->b);
        //binary_op = oldtype;
        return Binary::make(op->type(), op->op_type, new_a, new_b);
    }
    Expr visit(Ref<const Var> op) override {
        std::cout<<op->name<<endl;
        if (op->name == out_name) {
            out_var = new Expr(op);
            return Expr(0);
        }
        if (op-> name == grad_name) {
            grad_var = new Expr(op);
            return Expr(out_var->real_ptr());
        }
        //std::cout<<(int)binary_op<<endl;
        if (binary_op == BinaryOpType::Mul || binary_op == BinaryOpType::Div || binary_oop == BinaryOpType::Mul || binary_oop == BinaryOpType::Div)
        {
            return Var::make(op->type(), op->name, op->args, op->shape);
        }
        return Expr(0);
    }

    Group visit(Ref<const Kernel> op) override {
        grad_name = grads[0];
        out_name = outs[0];
        std::vector<Expr> new_inputs;
        for (auto expr : op->inputs) {
            new_inputs.push_back(mutate(expr));
        }
        std::vector<Expr> new_outputs;
        for (auto expr : op->outputs) {
            new_outputs.push_back(mutate(expr));
        }
        std::vector<Stmt> new_stmt_list;
        for (auto stmt : op->stmt_list) {
            new_stmt_list.push_back(mutate(stmt));
        }
        return Kernel::make(op->name, new_inputs, new_outputs, new_stmt_list, op->kernel_type);
    }
};

int tot_ins, tot_outs, tot_grads;

std::string kernel_file_name;
std::string vector_data_type;

Ref<const IRNode> TreeRoot;

int main( int argc, char * argv[] )
{

    std::vector<std::string> files;
    files.clear();
    files.push_back("./cases/case1.json");
    //files.push_back("./cases/case2.json");
    files.push_back("./cases/case3.json");
    //files.push_back("./cases/case4.json");
    files.push_back("./cases/case5.json");
    files.push_back("./cases/case6.json");
    files.push_back("./cases/case7.json");
    //files.push_back("./cases/case8.json");
    files.push_back("./cases/case9.json");
    //files.push_back("./cases/case10.json");
    for (unsigned int file_index = 0; file_index < files.size(); ++file_index)
    {
        varlist.clear();
        indexlist.clear();
        
        Json::CharReaderBuilder json_file_reader;
        Json::Value json_file_content;
        JSONCPP_STRING error_value;
        std::ifstream input_json(files[file_index], std::ios::binary);
        Json::parseFromStream(json_file_reader, input_json, &json_file_content, &error_value);

        std::string input_kernel = json_file_content["kernel"].asString();

        vector_data_type = json_file_content["data_type"].asString();
        kernel_file_name = json_file_content["name"].asString();
        
        std::cout << kernel_file_name << std::endl;
        std::cout << vector_data_type << std::endl;

        // ints outs 是gloabl 访问，printer可以拿到
        ins.clear();
        outs.clear();
        grads.clear();
        tot_ins = tot_outs = tot_grads = 0;

        for (auto ins_iter: json_file_content["ins"])
        {
            tot_ins += 1;
            std::string ins_str = ins_iter.asString();
            ins.push_back(ins_str);
        }

        // 注意 可能inputs 里面包含了 outputs
        for (auto outs_iter: json_file_content["outs"])
        {
            tot_outs += 1;
            std::string outs_str = outs_iter.asString();
            bool flag = 0;
            for(auto xi : ins)
            {
                if(xi == outs_str)
                {
                    flag = 1;
                    break;
                }
            }
            if(!flag)
                outs.push_back(outs_str);
        }

        for (auto grads_iter: json_file_content["grad_to"])
        {
            tot_grads += 1;
            std::string grads_str = grads_iter.asString();
            grads.push_back(grads_str);
        }


        // prase the kernel
        yy_input_string((char *)input_kernel.c_str());
        yyparse();
        
        cout << "Grammer tree done" << endl;
        std::shared_ptr<Boost::Internal::Kernel> kernel_p = std::const_pointer_cast<Boost::Internal::Kernel>(std::dynamic_pointer_cast<const Boost::Internal::Kernel>(TreeRoot.real_ptr()));
        kernel_p->name = kernel_file_name;
        kernel_p->datatype = vector_data_type;

        cout << "Begin translate by Printer " <<endl;

        //printer
        MyMutator mutator;
        //IRMutator mutator;
        Group kernel_pp = mutator.visit(kernel_p);
        std::shared_ptr<Boost::Internal::Kernel> kernel_ppp = std::const_pointer_cast<Boost::Internal::Kernel>(std::dynamic_pointer_cast<const Boost::Internal::Kernel>(kernel_pp.real_ptr()));
        kernel_ppp->datatype = vector_data_type;

        if (tot_grads == 1) {
            ins.clear();
            outs.clear();
            grads.clear();
            for (auto grads_iter: json_file_content["grad_to"])
            {
                std::string grads_str = grads_iter.asString();
                grads.push_back(grads_str);
            }
            for (auto ins_iter: json_file_content["ins"])
            {
                std::string ins_str = ins_iter.asString();
                if (ins_str != grads[0])
                {
                    ins.push_back(ins_str);
                }
            }
            for (auto outs_iter: json_file_content["outs"])
            {
                std::string outs_str = outs_iter.asString();
                outs.push_back(outs_str);
            }
            outs.push_back(grads[0]);
        }

        IRPrinter printer;
        std::string cpp_code = printer.print((Group)kernel_ppp);

        string save_file_path = "./kernels/" + kernel_file_name + ".cc";

        cout<<"translation finished! prepare to write "<<save_file_path<<endl;
        std::ofstream ofile(save_file_path, std::ios::out);
        ofile << cpp_code;

        //ofstream << 'anthing there?';
        ofile.close();
        //cout<<save_file_path<<"done!"<<endl;
    }


    return 0;
}