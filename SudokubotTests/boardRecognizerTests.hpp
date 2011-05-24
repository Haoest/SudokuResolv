#import <list>
using namespace std;

#import <SenTestingKit/SenTestingKit.h>

struct testPack{
    testPack(char InputFile[50], char boardHintAsString[89]);
    char inputFile[50];
    char hints[89];
};

@interface BoardRecognizerTests : SenTestCase {
    
}

class boardRecognizerTests{
public:
    boardRecognizerTests();
    ~boardRecognizerTests();
    void runAll();
    list<testPack*> tests;
};

@end
