#include <stdio.h>
#include <string>
#include <math.h>
#include <iostream>
using namespace std;

int p;

double resolve(string a){
	string aux;
	bool neg = false;

	if (a[0] == '-') {
		aux = "";
		neg = true;
		
		for (int i = 1; i < a.size(); i++) aux += a[i];
		
		a = aux;
	}

	if(a[0]=='('){
		p++;

		for (int i = 1; i < a.size()-1; i++) {
			if(a[i] == '(') {
				p++;
				continue;
			}

			if(a[i] == ')') {
				if(p) p--;
				if(p == 0) break;
				continue;
			}
		}

		if(p == 1) {
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

	if(a.size() == 1) {
		if(neg) return -a[0]-'0';
		return a[0]-'0';
	}


	for (int i = 0; i < a.size(); i++) {
		if(a[i] == '(') {
			p++;
			continue;
		}

		if(a[i] == ')') {
			if(p) p--;
			continue;
		}

		if(a[i] == '+' && !p) {
			string x,y;

			for (int j = 0; j < i; j++) x += a[j];
			
			for (int j = i+1; j < a.size(); j++) y += a[j];
			
			if(neg) return -resolve(x)+resolve(y); 
			return resolve(x)+resolve(y);
		}

		else if(a[i] == '-' && !p){
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

		if(a[i] == '*' && !p) {
			string x,y;

			for (int j = 0; j < i; j++) x += a[j];
			
			for (int j = i+1; j < a.size(); j++) y += a[j];
			
			if(neg) return -resolve(x)*resolve(y); 
			return resolve(x)*resolve(y);
		}

		else if(a[i] == '/' && !p) {
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

	if(ok) printf("Bem formatada\n%lf\n", resolve(x));
	else printf("Erro de formatação\n");
}