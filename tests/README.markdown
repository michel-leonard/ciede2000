# CIEDE 2000 Function Test

This is to test the consistency and accuracy of **CIEDE2000 formula implementations** across all supported programming languages.

## Symmetry Property of the CIEDE 2000 Functions

The developed `ciede_2000` functions produce the same result regardless of the order in which the two colors are provided. This **symmetry property**, essential for comparators, has been tested and verified 100,000,000 times in Go, JavaScript, PHP, Python and Rust. No further investigation has been conducted on this point to date by Michel Leonard since all implementations are syntactically similar.

## Test Samples

The `logs.txt` file presents the results of testing the `ciede_2000` function across 14 programming languages. This table contains an extract of the 1,365,000,000 test samples, to validate implementations of the CIEDE2000 color difference formula. Each row contains two colors in L* a* b* format, and the test is successful if the difference between ΔE2000 does not exceed `1e-10`.

| L1 | a1 | b1 | L2 | a2 | b2 | ΔE2000 | Possible Error in ΔE2000 |
|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
|73.0|49.0|39.4|73.0|49.0|39.4|0.0||
|30.0|-41.0|-119.1|30.0|-41.0|-119.0|0.0134319631||
|79.0|-117.0|-100.4|79.5|-117.0|-100.0|0.3572501235||
|15.0|-55.0|6.7|14.0|-55.0|7.0|0.6731711696||
|83.0|98.0|-59.5|85.2|98.0|-59.5|1.4597018301||
|59.0|-11.0|-95.0|56.3|-11.0|-95.0|2.4566352112||
|74.0|-1.0|68.6|81.0|-1.0|69.0|4.9755487499||
|46.4|125.0|6.0|40.0|125.0|6.0|5.8974138376||
|18.0|-5.0|68.0|20.0|5.0|82.0|6.8542258013||
|35.5|-99.0|109.0|25.0|-99.0|109.0|8.1462591143||
|59.0|77.0|41.5|63.3|77.0|12.4|13.1325726695||
|40.0|-92.0|7.7|58.0|-92.0|-8.0|19.1411733022||
|49.0|-9.0|-74.5|51.1|31.0|16.0|48.1082375109||
|88.0|-124.0|56.0|97.0|62.0|-28.0|63.9449872676|[101.4187274519](../#angle-conversions)|
|98.0|75.7|11.0|3.0|-62.0|11.0|126.5088270078||

> [!TIP]
> And to keep things simple? An [online tool](https://michel-leonard.github.io/ciede2000/samples.html) is available to explore additional CIEDE2000 color difference test samples, and when it's time to validate your implementation, a large-scale [validator](https://michel-leonard.github.io/ciede2000/batch.html) is in use.

## Results & Reliability

Tests [confirm](logs.txt#L298) that the computed **CIE ΔE2000** values remain identical, regardless of the programming language used for implementation.

## Comparison with ICC HDR Working Group Reference Data

To validate the ΔE2000 implementations, reference values ​​from the ICC HDR Working Group [document](https://www.color.org/groups/hdr/HDRWG-Summer2020.pdf) were used. The ΔE00 functions available in this repository reproduced them exactly, as shown in the following table, confirming the correctness of the implementations.

|L1|a1|b1|L2|a2|b2|Reference Value (PDF)|Computed Value|Deviation|
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
|100.0|0.0|0.0|0.0|0.0|0.0|100.0|[100.0](https://michel-leonard.github.io/ciede2000/calculator.html?L1=100&a1=0&b1=0&L2=0&a2=0&b2=0)|0%|
|100.0|0.0|0.0|100.0|0.0|0.0|0.0|[0.0](https://michel-leonard.github.io/ciede2000/calculator.html?L1=100&a1=0&b1=0&L2=100&a2=0&b2=0)|0%|
|50.0|2.5|0.0|73.0|25.0|-18.0|27.1492|[27.1492](https://michel-leonard.github.io/ciede2000/calculator.html?L1=50&a1=2.5&b1=0&L2=73&a2=25&b2=-18)|0%|
|50.0|2.5|0.0|61.0|-5.0|29.0|22.8977|[22.8977](https://michel-leonard.github.io/ciede2000/calculator.html?L1=50&a1=2.5&b1=0&L2=61&a2=-5&b2=29)|0%|
|50.0|2.5|0.0|56.0|-27.0|-3.0|31.903|[31.903](https://michel-leonard.github.io/ciede2000/calculator.html?L1=50&a1=2.5&b1=0&L2=56&a2=-27&b2=-3)|0%|
|50.0|2.5|0.0|58.0|24.0|15.0|19.4535|[19.4535](https://michel-leonard.github.io/ciede2000/calculator.html?L1=50&a1=2.5&b1=0&L2=58&a2=24&b2=15)|0%|
|84.25|5.74|96.0|84.46|8.88|96.49|1.6743|[1.6743](https://michel-leonard.github.io/ciede2000/calculator.html?L1=84.25&a1=5.74&b1=96&L2=84.46&a2=8.88&b2=96.49)|0%|
|84.25|5.74|96.0|84.52|5.75|93.09|0.5887|[0.5887](https://michel-leonard.github.io/ciede2000/calculator.html?L1=84.25&a1=5.74&b1=96&L2=84.52&a2=5.75&b2=93.09)|0%|
|84.25|5.74|96.0|84.37|5.86|99.42|0.6395|[0.6395](https://michel-leonard.github.io/ciede2000/calculator.html?L1=84.25&a1=5.74&b1=96&L2=84.37&a2=5.86&b2=99.42)|0%|

### Roundings

The common method for constructing the **computed values** is to multiply the ΔE2000 at the output of the function by 10,000, then round it to the nearest integer, and finally divide it by 10,000. This avoids any discrepancies in comparisons with ΔE2000 references.

## Comparison with University of Rochester Worked Examples

To validate the ΔE2000 implementations, the results were also compared with academic reference values from the [University of Rochester](https://hajim.rochester.edu/ece/sites/gsharma/ciede2000/ciede2000noteCRNA.pdf). To make sure, the hyperlinks to this [ΔE2000 calculator](https://bit.ly/ciede2000-calculator) can display the **computed values** with higher precision.

|L1|a1|b1|L2|a2|b2|Reference Value (PDF)|Computed Value|Deviation|
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
|50.0|2.6772|-79.7751|50.0|0.0|-82.7485|2.0425|[2.0425](https://michel-leonard.github.io/ciede2000/calculator.html?L1=50&a1=2.6772&b1=-79.7751&L2=50&a2=0&b2=-82.7485)|0%|
|50.0|3.1571|-77.2803|50.0|0.0|-82.7485|2.8615|[2.8615](https://michel-leonard.github.io/ciede2000/calculator.html?L1=50&a1=3.1571&b1=-77.2803&L2=50&a2=0&b2=-82.7485)|0%|
|50.0|2.8361|-74.02|50.0|0.0|-82.7485|3.4412|[3.4412](https://michel-leonard.github.io/ciede2000/calculator.html?L1=50&a1=2.8361&b1=-74.02&L2=50&a2=0&b2=-82.7485)|0%|
|50.0|-1.3802|-84.2814|50.0|0.0|-82.7485|1.0|[1.0](https://michel-leonard.github.io/ciede2000/calculator.html?L1=50&a1=-1.3802&b1=-84.2814&L2=50&a2=0&b2=-82.7485)|0%|
|50.0|-1.1848|-84.8006|50.0|0.0|-82.7485|1.0|[1.0](https://michel-leonard.github.io/ciede2000/calculator.html?L1=50&a1=-1.1848&b1=-84.8006&L2=50&a2=0&b2=-82.7485)|0%|
|50.0|-0.9009|-85.5211|50.0|0.0|-82.7485|1.0|[1.0](https://michel-leonard.github.io/ciede2000/calculator.html?L1=50&a1=-0.9009&b1=-85.5211&L2=50&a2=0&b2=-82.7485)|0%|
|50.0|0.0|0.0|50.0|-1.0|2.0|2.3669|[2.3669](https://michel-leonard.github.io/ciede2000/calculator.html?L1=50&a1=0&b1=0&L2=50&a2=-1&b2=2)|0%|
|50.0|-1.0|2.0|50.0|0.0|0.0|2.3669|[2.3669](https://michel-leonard.github.io/ciede2000/calculator.html?L1=50&a1=-1&b1=2&L2=50&a2=0&b2=0)|0%|
|50.0|2.49|-0.001|50.0|-2.49|0.0009|7.1792|[7.1792](https://michel-leonard.github.io/ciede2000/calculator.html?L1=50&a1=2.49&b1=-0.001&L2=50&a2=-2.49&b2=0.0009)|0%|
|50.0|2.49|-0.001|50.0|-2.49|0.001|7.1792|[7.1792](https://michel-leonard.github.io/ciede2000/calculator.html?L1=50&a1=2.49&b1=-0.001&L2=50&a2=-2.49&b2=0.001)|0%|
|50.0|2.49|-0.001|50.0|-2.49|0.0011|7.2195|[7.2195](https://michel-leonard.github.io/ciede2000/calculator.html?L1=50&a1=2.49&b1=-0.001&L2=50&a2=-2.49&b2=0.0011)|0%|
|50.0|2.49|-0.001|50.0|-2.49|0.0012|7.2195|[7.2195](https://michel-leonard.github.io/ciede2000/calculator.html?L1=50&a1=2.49&b1=-0.001&L2=50&a2=-2.49&b2=0.0012)|0%|
|50.0|-0.001|2.49|50.0|0.0009|-2.49|4.8045|[4.8045](https://michel-leonard.github.io/ciede2000/calculator.html?L1=50&a1=-0.001&b1=2.49&L2=50&a2=0.0009&b2=-2.49)|0%|
|50.0|-0.001|2.49|50.0|0.001|-2.49|4.8045|[4.8045](https://michel-leonard.github.io/ciede2000/calculator.html?L1=50&a1=-0.001&b1=2.49&L2=50&a2=0.001&b2=-2.49)|0%|
|50.0|-0.001|2.49|50.0|0.0011|-2.49|4.7461|[4.7461](https://michel-leonard.github.io/ciede2000/calculator.html?L1=50&a1=-0.001&b1=2.49&L2=50&a2=0.0011&b2=-2.49)|0%|
|50.0|2.5|0.0|50.0|0.0|-2.5|4.3065|[4.3065](https://michel-leonard.github.io/ciede2000/calculator.html?L1=50&a1=2.5&b1=0&L2=50&a2=0&b2=-2.5)|0%|
|50.0|2.5|0.0|50.0|3.1736|0.5854|1.0|[1.0](https://michel-leonard.github.io/ciede2000/calculator.html?L1=50&a1=2.5&b1=0&L2=50&a2=3.1736&b2=0.5854)|0%|
|50.0|2.5|0.0|50.0|3.2972|0.0|1.0|[1.0](https://michel-leonard.github.io/ciede2000/calculator.html?L1=50&a1=2.5&b1=0&L2=50&a2=3.2972&b2=0)|0%|
|50.0|2.5|0.0|50.0|1.8634|0.5757|1.0|[1.0](https://michel-leonard.github.io/ciede2000/calculator.html?L1=50&a1=2.5&b1=0&L2=50&a2=1.8634&b2=0.5757)|0%|
|50.0|2.5|0.0|50.0|3.2592|0.335|1.0|[1.0](https://michel-leonard.github.io/ciede2000/calculator.html?L1=50&a1=2.5&b1=0&L2=50&a2=3.2592&b2=0.335)|0%|
|60.2574|-34.0099|36.2677|60.4626|-34.1751|39.4387|1.2644|[1.2644](https://michel-leonard.github.io/ciede2000/calculator.html?L1=60.2574&a1=-34.0099&b1=36.2677&L2=60.4626&a2=-34.1751&b2=39.4387)|0%|
|63.0109|-31.0961|-5.8663|62.8187|-29.7946|-4.0864|1.263|[1.263](https://michel-leonard.github.io/ciede2000/calculator.html?L1=63.0109&a1=-31.0961&b1=-5.8663&L2=62.8187&a2=-29.7946&b2=-4.0864)|0%|
|61.2901|3.7196|-5.3901|61.4292|2.248|-4.962|1.8731|[1.8731](https://michel-leonard.github.io/ciede2000/calculator.html?L1=61.2901&a1=3.7196&b1=-5.3901&L2=61.4292&a2=2.248&b2=-4.962)|0%|
|35.0831|-44.1164|3.7933|35.0232|-40.0716|1.5901|1.8645|[1.8645](https://michel-leonard.github.io/ciede2000/calculator.html?L1=35.0831&a1=-44.1164&b1=3.7933&L2=35.0232&a2=-40.0716&b2=1.5901)|0%|
|22.7233|20.0904|-46.694|23.0331|14.973|-42.5619|2.0373|[2.0373](https://michel-leonard.github.io/ciede2000/calculator.html?L1=22.7233&a1=20.0904&b1=-46.694&L2=23.0331&a2=14.973&b2=-42.5619)|0%|
|36.4612|47.858|18.3852|36.2715|50.5065|21.2231|1.4146|[1.4146](https://michel-leonard.github.io/ciede2000/calculator.html?L1=36.4612&a1=47.858&b1=18.3852&L2=36.2715&a2=50.5065&b2=21.2231)|0%|
|90.8027|-2.0831|1.441|91.1528|-1.6435|0.0447|1.4441|[1.4441](https://michel-leonard.github.io/ciede2000/calculator.html?L1=90.8027&a1=-2.0831&b1=1.441&L2=91.1528&a2=-1.6435&b2=0.0447)|0%|
|90.9257|-0.5406|-0.9208|88.6381|-0.8985|-0.7239|1.5381|[1.5381](https://michel-leonard.github.io/ciede2000/calculator.html?L1=90.9257&a1=-0.5406&b1=-0.9208&L2=88.6381&a2=-0.8985&b2=-0.7239)|0%|
|6.7747|-0.2908|-2.4247|5.8714|-0.0985|-2.2286|0.6377|[0.6377](https://michel-leonard.github.io/ciede2000/calculator.html?L1=6.7747&a1=-0.2908&b1=-2.4247&L2=5.8714&a2=-0.0985&b2=-2.2286)|0%|
|2.0776|0.0795|-1.135|0.9033|-0.0636|-0.5514|0.9082|[0.9082](https://michel-leonard.github.io/ciede2000/calculator.html?L1=2.0776&a1=0.0795&b1=-1.135&L2=0.9033&a2=-0.0636&b2=-0.5514)|0%|

## Analysis

The **computed values** show perfect agreement with all reference values. With slightly increased precision, the results align with those from [brucelindbloom.com](http://www.brucelindbloom.com/index.html?ColorDifferenceCalc.html), confirming the correctness of this cross-language implementation of the CIEDE2000 color difference formula.
