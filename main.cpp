#include "Detector.h"
#include "timer.h"

Mat ga, gb;

int main(int argc, char* argv[])
{
    Mat img1 = imread(argv[1]);
    Mat img2 = imread(argv[2]);

    cv::cvtColor(img1, ga, cv::COLOR_BGR2GRAY);
    cv::cvtColor(img2, gb, cv::COLOR_BGR2GRAY);

    Timer t;
    t.start();

    CDetector* d = new CDetector(ga);
    vector<Point2d> ct = d->Detect(gb);

    cout << t.count() << endl;

    cout << ct.size() << endl;

    for (int i = 0; i < ct.size(); i++) {
        circle(img2, ct[i], 2, Scalar(0, 0, 255));
    }
    imwrite("res.jpg", img2);
}
