### Quarter Mile Time estimator

Uses the mtcars dataset (below) and a linear regression to estimate quarter
 mile times for cars

```
                  mpg cyl disp  hp drat    wt  qsec vs am gear carb
Mazda RX4         21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
Mazda RX4 Wag     21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
Datsun 710        22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
Hornet 4 Drive    21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
Hornet Sportabout 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2
Valiant           18.1   6  225 105 2.76 3.460 20.22  1  0    3    1
```

### Example Input

```
{
  "mpg": 21,
  "cyl": 6,
  "disp": 160,
  "hp": 110,
  "drat": 3.9,
  "wt": 2.62,
  "gea": 4,
  "carb": 4
}
```


Result

```
{
  "status": "OK",
  "timestamp": "2018-02-27T22:50:50.125Z",
  "result": [
    {
      "prediction": 16.8394
    }
  ],
  "promote_id": "dcd1da89-581d-4da3-911c-6d6fe1bd902a",
  "model_name": "QuarterMileTime",
  "model_version": "1"
}
```