/*
2023.08.24
目标：
    1. 更好的注释系统。‘#’应该不仅仅只有在行首时生效
    2. 更好的纠错机制。当关键词写错时应当终止映射。
        以及注意这条并没有保证一切映射、命名方式合法
    3. 常量应当至少支持二进制、十进制以及十六进制的表达。
    4. 重构代码。
*/

#include<fstream>
#include<string>
#include<iomanip>
#include<map>
#include<iostream>
#include<algorithm>
#include<sstream>
using namespace std;
string SOURCE = ""; //汇编代码路径
string TARGET = "src\\ROM_32bit\\ROM_32bit.v"; //ROM_32bit.v的路径
ifstream fin;
ofstream fout;
map<string, int> table;
unsigned char arr[8192];
int tot;
void LOAD(){
    fin.close();
    fout.close();
    fin.open("table", ios::in);
    string s;
    int num;
    while(fin >> s >> num){
        table[s] = num;
    }
}
void LOAD_LABEL(){
    string s;
    fin.close();
    fin.open(SOURCE, ios::in);
    int id = 0;
    while(getline(fin, s)){
        stringstream ss;
        for(auto& i : s) i = toupper(i);
        ss << s;
        ss >> s;
        if (s.empty() || s[0] == '#') continue;
        if (s == "LABEL"){
            ss >> s;
            table[s] = id;
        }
        else {
            ++id;
        }
    }
}
int readbin(string& s){
    int res = 0;
    for (int i = 2; i < s.size(); ++i){
        res = res * 2 + (s[i] == '1');
    }
    return res;
}
bool ANALYZE(string& s){
    string t;
    for (int i = 0; i < s.size(); ++i){
        if (s[i] == '+' || s[i] == '-' || s[i] == '|' || s[i] == '^' || s[i] == '&'){
            t += ' ';
            t += s[i];
            t += ' ';
        }
        else{
            t += s[i];
        }
    }
    s = t;
    stringstream ss;
    ss << s;
    int res = 0;
    char op = '+';
    while(ss >> s){
        if (s[0] == '+' || s[0] == '-' || s[0] == '|' || s[0] == '^' || s[0] == '&'){
            op = s[0];
            continue;
        }
        int dres = 0;
        if (isdigit(s[0])){
            stringstream tt;
            tt << s;
            if (s.size() == 1 || isdigit(s[1])){
                tt >> dres;
            }
            else{
                if (s[1] == 'X') tt >> hex >> dres;
                else if (s[1] == 'B') dres = readbin(s);
                else return false;
            }
        }
        else{
            if (s[0] == '#') return false;
            auto it = table.find(s);
            if (it == table.end()) return false;
            dres = it->second;
        }
        if(op == '+')
            res += dres;
        else if(op == '-')
            res -= dres;
        else if(op == '&')
            res &= dres;
        else if(op == '|')
            res |= dres;
        else if(op == '^')
            res ^= dres;
    }
    arr[tot++] = res;
    return true;
}
bool COMPILE(){
    fin.close();
    fin.open(SOURCE, ios::in);
    string s, a, b, c, t;
    while(getline(fin, s)){
        stringstream ss;
        t.clear();
        for (int i = 0; i < s.size(); ++i){
            if (s[i] == '+' || s[i] == '-' || s[i] == '|' || s[i] == '^' || s[i] == '&'){
                if (i == 0 || i == s.size() - 1) 
                    return false;
                if (s[i - 1] == ' '){
                    t.pop_back();
                    t += s[i];
                }
                else{
                    t += s[i];
                }
                if(s[i + 1] == ' '){
                    ++i;
                }
            }
            else if (s[i] == '#'){
                t += ' ';
                t += s[i];
            }
            else{
                t += toupper(s[i]);
            }
        }
        s = t;
        ss << s;
        s.clear();
        ss >> s;
        if (s.empty() || s == "LABEL" || s[0] == '#'){
            continue;
        }
        else {
            ss >> a >> b >> c;
            if (!ANALYZE(s)) 
                return false;
            if (!ANALYZE(a)) 
                return false;
            if (!ANALYZE(b)) 
                return false;
            if (!ANALYZE(c)) 
                return false;
            cout << s << " " << a << " " << b << " " << c << "\n";
        }
    }
    return true;
}
void BUILD(){
    fout.close();
    fout.open(TARGET, ios::out);
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
    if (COMPILE()) BUILD(), cerr << "Done.";
    else cerr << "Wrong.\n";
    fout.flush();
    cin.get();
    return 0;
}