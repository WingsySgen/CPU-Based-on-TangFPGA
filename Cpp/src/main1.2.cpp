//2023.02.06
//添加了注释功能，使用'#'在行首来注释一行内容
//release版本
#include<fstream>
#include<string>
#include<iomanip>
#include<map>
#include<iostream>
#include<algorithm>
#include<sstream>
using namespace std;
string SOURCE = "D:\\Data\\VSCode\\C++\\8bitcpu汇编编译\\UARTtest.code";
// string TARGET = "D:\\Data\\FPGA_PROJECT\\Top\\src\\ROM_32bit\\ROM_32bit.v";
string TARGET = "D:\\Data\\FPGA_PROJECT\\8bitCPU_test\\src\\ROM_32bit\\ROM_32bit.v";
ifstream fin;
ofstream fout;
map<string, int> table;
unsigned char arr[8192];
int tot;
void LOAD(){
    fin.close();
    fout.close();
    fin.open("D:\\Data\\VSCode\\C++\\8bitcpu汇编编译\\table", ios::in);
    string s;
    int num;
    while(fin >> s >> num){
        table[s] = num;
        // cout << s << "\n";
    }
}
void LOAD_LABEL(){
    string s, a;
    fin.close();
    fin.open(SOURCE, ios::in);
    int id = 0;
    while(fin >> s){
        for(auto&i : s) i = toupper(i);
        if (s == "LABEL"){
            fin >> a;
            for(auto&i : a) i = toupper(i);
            table[a] = id;
        }
        else if (s[0] != '#'){
            getline(fin, a);
            ++id;
        }
    }
}
void ANSALYZE(string&s){
    int res = 0;
    if(isdigit(s[0])){
        for(auto i : s){
            res = res * 10 + i - '0';
        }
    }
    else{
        char op = '+';
        string temp;
        for(auto i : s){
            if (isalpha(i) || isdigit(i) || i == '_' || i == '.') temp += i;
            else{
                if(op == '+')
                    res += table[temp];
                else if(op == '-')
                    res -= table[temp];
                else if(op == '&')
                    res &= table[temp];
                else if(op == '|')
                    res |= table[temp];
                else if(op == '^')
                    res ^= table[temp];
                op = i;
                temp.clear();
            }
        }
        if(op == '+')
            res += table[temp];
        else if(op == '-')
            res -= table[temp];
        else if(op == '&')
            res &= table[temp];
        else if(op == '|')
            res |= table[temp];
        else if(op == '^')
            res ^= table[temp];
        temp.clear();
    }
    arr[tot++] = res;
}
void COMPILE(){
    fin.close();
    fin.open(SOURCE, ios::in);
    string s, a, b, c;
    while(fin >> s){
        for(auto&i : s) i = toupper(i);
        if (s == "LABEL"){
            fin >> a;
        }
        else if (s[0] != '#'){
            fin >> a >> b >> c;
            for(auto&i : a) i = toupper(i);
            for(auto&i : b) i = toupper(i);
            for(auto&i : c) i = toupper(i);
            ANSALYZE(s);
            ANSALYZE(a);
            ANSALYZE(b);
            ANSALYZE(c);
            cout << s << " " << a << " " << b << " " << c << "\n";
        }
        else {
            getline(fin, a);
        }
    }
}
void BUILD(){
    fout.close();
    fout.open(TARGET, ios::out);
    // fout.open("D:\\Data\\VSCode\\C++\\8bitcpu汇编编译\\test.v", ios::out);
    fout << "module ROM_32bit (dout, clk, oce, ce, reset, ad);\n"
         << "output [31:0] dout;"
         << "\n"
         << "input clk;"
         << "\n"
         << "input oce;"
         << "\n"
         << "input ce;"
         << "\n"
         << "input reset;"
         << "\n"
         << "input [7:0] ad;"
         << "\n"
         << ""
         << "\n"
         << "wire gw_gnd;"
         << "\n"
         << ""
         << "\n"
         << "assign gw_gnd = 1'b0;"
         << "\n"
         << ""
         << "\n"
         << "pROM prom_inst_0 ("
         << "\n"
         << "    .DO(dout[31:0]),"
         << "\n"
         << "    .CLK(clk),"
         << "\n"
         << "    .OCE(oce),"
         << "\n"
         << "    .CE(ce),"
         << "\n"
         << "    .RESET(reset),"
         << "\n"
         << "    .AD({gw_gnd,ad[7:0],gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd})"
         << "\n"
         << ");"
         << "\n"
         << ""
         << "\n"
         << "defparam prom_inst_0.READ_MODE = 1'b0;"
         << "\n"
         << "defparam prom_inst_0.BIT_WIDTH = 32;"
         << "\n"
         << "defparam prom_inst_0.RESET_MODE = \"SYNC\";"
         << "\n\n";
    int bound = (tot + 31) / 32;
    fout.setf(ios::hex, ios::basefield);
    fout.setf(ios::uppercase);
    for (int i = 0; i < bound; ++i){
        fout << "defparam prom_inst_0.INIT_RAM_" << setw(2) << setfill('0') << (int)i;
        fout << " = 256'h";
        for (int j = 31; j >= 0; --j){
            fout << setw(2) << setfill('0') << (int)arr[i * 32 + j];
        }
        fout << ";\n";
    }
    fout << "\nendmodule\n";
}
int main(){
    LOAD();
    LOAD_LABEL();
    COMPILE();
    BUILD();
    return 0;
}