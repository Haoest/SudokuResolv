#import <list>

using namespace std;

int** loadStringAsBoard(char boardAsString[89]);

struct testPack{
    testPack(char InputFile[50], char boardHintAsString[89]);
    char inputFile[50];
    char hints[89];
};

class boardRecognizerTests{
public:
    boardRecognizerTests();
    ~boardRecognizerTests();
    void runAll();
    list<testPack*> tests;
};
	