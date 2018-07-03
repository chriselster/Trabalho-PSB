#include <stdio.h>
#include <string>
#include <math.h>
#include <iostream>
using namespace std;

//contador de parênteses
int p;

bool isNum(string s){
	bool ok = true;
	for (int i = 0; i < s.size(); ++i)
	{
		if((s[i]>'9' || s[i]< '0')&& s[i]!=',') ok = false;
	}
	return ok;
}

float toNum(string s){
	float x = 0, y;
	int j = 0;
	for (int i = s.size()-1; i >= 0; --i)
	{
		if(s[i]!= ',') x +=( s[i]-'0') * pow(10,j++);
		else y = j;
	}
	x /= pow(10,y);
	return x;
}

double resolve(string a){
	string aux;
	cout<<a<<endl;

	//flag caso primeiro operando seja negativo
	bool neg = false;

	if (a[0] == '-') {
		//aciona a flag e remove o sinal de menos
		aux = "";
		neg = true;
		
		for (int i = 1; i < a.size(); i++) aux += a[i];
		
		a = aux;
	}


	if(a[0]=='('){
		p++;
		//checa se os parênteses envolvem a expressão toda
		//ex: ((a+b)*c+d)
		for (int i = 1; i < a.size()-1; i++) {
			if(a[i] == '(') {
				p++;
				continue;
			}

			if(a[i] == ')') {
				if(p) p--;
				if(p == 0) break;
			}
		}

		if(p == 1) {
			//tira os parênteses de fora
			//e chama a recursão dentro
			//(2+3) -> 2+3
			aux = "";
			for (int i = 1; i < a.size(); i++) aux += a[i];
			a=aux;

			aux = "";
			for (int i = 0; i < a.size()-1; i++) aux += a[i];
			a=aux;

			p--;
			if(neg) return -resolve(a);
			return resolve(a);
		}
	}
	

	//caso básico
	if(isNum(a)) {
		if(neg) return -toNum(a);
		return toNum(a);
	}

	/*---------------------------------------------*/
	/* se a recursão chegar aqui obrigatoriamente
	   existe pelo menos um operador fora de 
	   parênteses                                  */
	/*---------------------------------------------*/

	//busca por esse operador
	for (int i = 0; i < a.size(); i++) {

		//se p != 0, a[i] está entre parênteses
		//ex: (3+5)-2  e a[i] = 3
		if(a[i] == '(') {
			p++;
			continue;
		}

		if(a[i] == ')') {
			if(p) p--;
			continue;
		}

		//busca pelos operadores de menor precedência
		//ou seja, + e - fora de parênteses
		if(a[i] == '+' && !p) {
			//se achar divide a string em outras duas:
			//os operandos
			string x,y;

			for (int j = 0; j < i; j++) x += a[j];
			
			for (int j = i+1; j < a.size(); j++) y += a[j];
			
			if(neg) return -resolve(x)+resolve(y); 
			return resolve(x)+resolve(y);
		}

		else if(a[i] == '-' && !p){
			//se achar divide a string em outras duas:
			//os operandos
			string x,y;

			for (int j = 0; j < i; j++) x += a[j];
			
			for (int j = i; j < a.size(); j++) y += a[j];
			
			if(neg) return -resolve(x)+resolve(y); 
			return resolve(x)+resolve(y);
		}
	}


	for (int i = a.size()-1; i >=0; i--) {
		if(a[i] == ')') {
			p++;
			continue;
		}

		if(a[i] == '(') {
			if(p) {
				p--;
			}
			continue;
		}

		//como não há + e - fora de parênteses
		//busca por * e / fora de parênteses
		if(a[i] == '*' && !p) {
			//se achar divide a string em outras duas:
			//os operandos
			string x,y;

			for (int j = 0; j < i; j++) x += a[j];
			
			for (int j = i+1; j < a.size(); j++) y += a[j];
			
			if(neg) return -resolve(x)*resolve(y); 
			return resolve(x)*resolve(y);
		}

		else if(a[i] == '/' && !p) {
			//se achar divide a string em outras duas:
			//os operandos
			string x,y;

			for (int j = 0; j < i; j++) x += a[j];
			
			for (int j = i+1; j < a.size(); j++) y += a[j];
			
			if(neg) return -resolve(x)/resolve(y); 
			return resolve(x)/resolve(y);
		}
	}
}

int main() {
	bool ok = true;
	string a,x;
	getline (cin,a);

	for (int i = 0; i < a.size(); i++){
		if(a[i] != ' ') x += a[i];
	}

	for (int i = 0; i < a.size(); i++) {
		if(a[i] == '('){
			p++;
			continue;
		}

		if(a[i] == ')'){
			if(p > 0) p--;
			
			else {
				ok = false;
				break;
			}
		}
	}
	if(p!= 0)ok = false;

	if(ok) printf("Bem formatada\n%lf\n", resolve(x));
	else printf("Erro de formatação\n");
}