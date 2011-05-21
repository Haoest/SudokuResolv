#import <list>

using namespace std;

void runAllBoardRecognizerTests();

struct testPack{
    testPack(char InputFile[255], int**Hints, int**GameSolution=0);
    ~testPack();
    char inputFile[255];
    int **hints;
    int **gameSolution;
};

struct boardRecognizerTests{
    boardRecognizerTests();
    ~boardRecognizerTests();
    void runAll();
    list<testPack*> tests;
};
	