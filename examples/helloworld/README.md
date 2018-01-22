## Hello World!

Build a model that takes in the data below and returns a greeting.

```
{
  "name": "colin"
}
```
 
### Model Response:

```
"Hello colin !"
```

### Example Request:
```
$ curl -X POST -H "Content-Type: application/json"   --user username:apikey   --data '{"name":"colin"}'   http://promote_url.com/colin/models/HelloWorld/predict

{
  "result": "Hello colin !",
  "promote_id": "958b9839-bf97-427c-8bd7-07409d9df3b5",
  "promote_model": "HelloWorld",
  "status": "OK",
  "timestamp": "2017-11-16T18:50:42.138Z"
}
```
