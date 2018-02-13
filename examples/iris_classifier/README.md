### Iris Classifier

This model uses a RandomForest algorithm to classify different flower species:

Iris Setosa, Iris Versicolor, Iris Verginica

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/Kosaciec_szczecinkowaty_Iris_setosa.jpg/440px-Kosaciec_szczecinkowaty_Iris_setosa.jpg" height="150px"/>

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/4/41/Iris_versicolor_3.jpg/440px-Iris_versicolor_3.jpg" height="150px"/>

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/9/9f/Iris_virginica.jpg/440px-Iris_virginica.jpg" height="150px" />

Sample Request data for a prediction:
```
{
  "sepal_length": 5.1,
  "sepal_width": 4.5,
  "petal_length": 3.4,
  "petal_width": 2.2
}
```

`train.R` demonstrates how to deploy this model directly from within an R console.
`deploy_irisClassifier.yxmd` demonstrates how to build the same model using Alteryx Designers' R tool
`deploy_tool_irisClassifier.yxmd` demonstrates how to build the same model using Alteryx Designers' RandomForest tool

![](./deploy_irisClassifier_workflow.png)
![](./deploy_tool_irisClassifier.png)


