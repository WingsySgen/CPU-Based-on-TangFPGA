/*
2023.09.28
目标：
    1. 修复bug：一个仅有空格的空行会使得label识别错误。
    2. 支持导出日志文件、编译信息。提供更全面的编译信息（报错信息等）。
*/

#include<fstream>
#include<string>
#include<iomanip>
#include<map>
#include<iostream>
#include<algorithm>
#include<sstream>
#include<ctime>
using namespace std;
string SOURCE = "";
string TARGET = "\\src\\ROM_32bit\\ROM_32bit.v";
ofstream flog;
ifstream fin;
ofstream fout;
map<string, int> table;
unsigned char arr[8192];
int tot;
bool openLOG = true;
void LOG(){
    if (openLOG) {
        flog.open("D:\\Data\\VSCode\\C++\\8bitcpu汇编编译_8bit\\log");
        time_t now;
        time(&now);
        flog << ctime(&now) << endl;
        flog << "SOURCE = " << SOURCE << endl;
        flog << "TARGET = " << TARGET << endl << endl;
    }
}
void LOAD(){
    fin.close();
    fout.close();
    fin.open("D:\\Data\\VSCode\\C++\\8bitcpu汇编编译_8bit\\table", ios::in);
    string s;
    int num;
    while (fin >> s >> num) {
        table[s] = num;
    }
}
bool LOAD_LABEL(){
    if (openLOG) {
        flog << "label:" << endl;
    }
    string s;
    fin.close();
    fin.open(SOURCE, ios::in);
    int id = 0;
    while(getline(fin, s)){
        reverse(s.begin(), s.end());
        while(!s.empty()){
            if (s.back() == ' ' || s.front() == '\n' || s.front() == '\r' || s.front() == '\t') s.pop_back();
            else break;
        }
        if (s.empty()) continue;
        reverse(s.begin(), s.end());

        stringstream ss;
        for(auto& i : s) i = toupper(i);
        ss << s;
        ss >> s;
        if (s.empty() || s[0] == '#') continue;
        if (s == "LABEL"){
            ss >> s;
            if (table.find(s) != table.end()){
                if (openLOG){
                    flog << "Wrong." << endl;
                    flog << "label \"" << s << "\" redefined." << endl;
                }
                return false;
            }
            table[s] = id;
            if (openLOG) {
                flog << setw(35) << left << s << " = " << right << setw(5) << dec << id << "(" << hex << id << ")" << endl;
            }
        }
        else {
            ++id;
        }
    }
    if (openLOG) {
        flog << endl;
    }
    return true;
}
int readbin(string& s){
    int res = 0;
    for (int i = 2; i < s.size(); ++i){
        res = res * 2 + (s[i] == '1');
    }
    return res;
}
bool ANALYZE(string& s){
    //分析单条指令
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
    //汇编所有代码
    fin.close();
    fin.open(SOURCE, ios::in);
    string s, a, b, c, t;
    while(getline(fin, s)){
        reverse(s.begin(), s.end());
        while(!s.empty()){
            if (s.back() == ' ' || s.front() == '\n' || s.front() == '\r' || s.front() == '\t') s.pop_back();
            else break;
        }
        if (s.empty()) continue;
        reverse(s.begin(), s.end());
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
            if (openLOG){
                flog << "\n";
                flog << setw(5) << dec << (tot >> 2);
                flog << " |";
                flog << setw(3) << hex << (tot >> 2) << "    ";
            }
            ss >> a >> b >> c;
            t = s;
            if (!ANALYZE(s)) {
                if (openLOG){
                    flog << endl;
                    flog << "Wrong.\n";
                    flog << "invalid \"" << t << "\"" << endl;
                }
                return false;
            }
            if (openLOG){
                flog << t << " ";
            }
            t = a;
            if (!ANALYZE(a)) {
                if (openLOG){
                    flog << endl;
                    flog << "Wrong.\n";
                    flog << "invalid \"" << t << "\"" << endl;
                }
                return false;
            }
            if (openLOG){
                flog << t << " ";
            }
            t = b;
            if (!ANALYZE(b)) {
                if (openLOG){
                    flog << endl;
                    flog << "Wrong.\n";
                    flog << "invalid \"" << t << "\"" << endl;
                }
                return false;
            }
            if (openLOG){
                flog << t << " ";
            }
            t = c;
            if (!ANALYZE(c)) {
                if (openLOG){
                    flog << endl;
                    flog << "Wrong.\n";
                    flog << "invalid \"" << t << "\"" << endl;
                }
                return false;
            }
            if (openLOG){
                flog << t;
            }
            cout << s << " " << a << " " << b << " " << c << "\n";
        }
    }
    if (tot >= 1024){
        if (openLOG){
            flog << "\n";
            flog << "Wrong.\n";
            flog << "oversized instructions." << endl;
        }
        return false;
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
int main(int argc, char* argv[]){
    if (argc > 1) SOURCE = argv[1];
    cout << SOURCE << "\n";
    LOG();
    LOAD();
    if (!LOAD_LABEL()) cerr << "Wrong.\n", cin.get();
    if (COMPILE()) BUILD(), cerr << "Done.";
    else cerr << "Wrong.\n", cin.get();
    fout.flush();
    return 0;
}