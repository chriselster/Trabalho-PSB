#include <bits/stdc++.h>

using namespace std;

int pos = 0;

bool isNum(char c) {return c >= '0' && c <= '9';}

int calcula(string s, int i) {
	printf("%c %d\n", s[i], i);

	if (s[i] == '(') {
		int res = calcula(s, i+1);
		printf("%c %d %d\n", s[i], i, res);

		if (pos+1 >= s.size()) {
			if (i>0) {
				if (s[i-1] == '-') return -res;
				else return res;

			} else return res;
		}

		if (s[pos+1] == '+' || s[pos+1] == '-') {
			int res2 = calcula(s, pos+2);
			if (i>0 && s[i-1] == '-') return -res+res2;
			else return res+res2;

		} else if (s[pos+1] == ')') {
			pos = pos+1;
			if (i>0 && s[i-1] == '-') return -res;
			else return res;
		}
	} else if (isNum(s[i])) {
		if (i+1 >= s.size()) {
			pos = i;
			if (i>0 && s[i-1] == '-') return -(s[i]-'0');
			else return (s[i]-'0');
		}

		if (s[i+1] == '+' || s[i+1] == '-') {

			int res = calcula(s, i+2);
			printf("%c %d %d\n", s[i], i, res);

			if (i>0 && s[i-1] == '-') return -(s[i]-'0')+res;
			else return (s[i]-'0')+res;

			if (i>0 && (s[i-1] == '*' || s[i-1] == '/')) {
				pos = i;
				return s[i]-'0';
			}
			
			
		} else if (s[i+1] == '*' || s[i+1] == '/') {
			int res = calcula(s, i+2);

			if (pos+1 >= s.size()) {
				if (i>0) {
					if (s[i-1] == '-') return -res;
					else return res;

				} else return res;
			} else if (s[pos+1] == '+' || s[pos+1] == '-') {
				int res2 = calcula(s, pos+2);
				if (i>0 && s[i-1] == '-') return -res+res2;
				else return res+res2;
			}



			
		} else if (s[i+1] == ')') {
			pos = i+1;
			if (i>0 && s[i-1] == '-') return -(s[i]-'0');
			else return (s[i]-'0');
		}


	}

}

int main() {
	string expressao;

	cin >> expressao;

	cout << calcula(expressao, 0) << endl;
}

//3*4+5
//3*(4+5)
// ((3+4)*(4+5))