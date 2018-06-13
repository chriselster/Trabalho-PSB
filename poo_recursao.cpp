#include <bits/stdc++.h>
using namespace std;

stack<char> p;

bool isNum(string a){
	for (int i = 0; i < a.size(); ++i)
	{
		if(a[i]<'0' || a[i]>'9'){
			return false;
		}
	}
	return true;
}

int valor(string a){
	int tot = 0;
	for (int i = 0; i < a.size(); ++i)
	{
		tot+=pow(10,a.size()-1-i)*(a[i]-'0');
	}
	return tot;
}


double resolve(string a){
	cout<<a<<endl;
	bool neg = false;
	if(a[0] == '-'){
		neg = true;
		a.erase(a.begin());
	}

	if(a[0]=='('){
		p.push('(');
		for (int i = 1; i < a.size()-1; ++i)
		{
			if(a[i] == '('){
				p.push(a[i]);
				continue;
			}

			if(a[i] == ')'){
				if(p.size()){
					p.pop();
				}
				if(p.size()==0)break;
				continue;
			}
		}
		if(p.size()==1){
			a.erase(a.begin());
			a.erase(a.end()-1);
			p.pop();
			if(neg) return -resolve(a);
			return resolve(a);
		}
	}

	if(isNum(a)){
		if(neg)return -valor(a);
		return valor(a);
	}


	for (int i = 0; i < a.size(); ++i)
	{
		if(a[i] == '('){
			p.push(a[i]);
			continue;
		}

		if(a[i] == ')'){
			if(p.size()){
				p.pop();
			}
			continue;
		}

		if(a[i] == '+' && !p.size()){
			string x,y;
			for (int j = 0; j < i; ++j)
			{
				x+=a[j];
			}
			for (int j = i+1; j < a.size(); ++j)
			{
				y+=a[j];
			}
			if(neg) return -resolve(x)+resolve(y); 
			return resolve(x)+resolve(y);
		}

		else if(a[i] == '-' && !p.size()){
			string x,y;
			for (int j = 0; j < i; ++j)
			{
				x+=a[j];
			}
			for (int j = i; j < a.size(); ++j)
			{
				y+=a[j];
			}
			return resolve(x)+resolve(y);
		}
	}

	for (int i = a.size()-1; i >=0; --i)
	{
		if(a[i] == ')'){
			p.push(a[i]);
			continue;
		}

		if(a[i] == '('){
			if(p.size()){
				p.pop();
			}
			continue;
		}

		if(a[i] == '*' && !p.size()){
			string x,y;
			for (int j = 0; j < i; ++j)
			{
				x+=a[j];
			}
			for (int j = i+1; j < a.size(); ++j)
			{
				y+=a[j];
			}
			if(neg) return -resolve(x)*resolve(y); 
			return resolve(x)*resolve(y);
		}

		else if(a[i] == '/' && !p.size()){
			string x,y;
			for (int j = 0; j < i; ++j)
			{
				x+=a[j];
			}
			for (int j = i+1; j < a.size(); ++j)
			{
				y+=a[j];
			}
			if(neg) return -resolve(x)/resolve(y); 
			return resolve(x)/resolve(y);
		}
	}

}

int main(){
	string a,x;
	getline (cin,a);
	for (int i = 0; i < a.size(); ++i)
	{
		if(a[i]!=' ')x+=a[i];
	}
	cout<<resolve(x)<<endl;
}