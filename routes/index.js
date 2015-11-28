var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/api/v1/resume', function (req, res, next) {
  res.json([
    {id:1, make: 'Martin', model: 'D15'},
    {id:2, make: 'Taylor', model: 'DN14'}
  ]);
});

router.get('*', function(req, res, next) {
  res.sendFile('index.html', {
    root: __dirname + '/../public/'
  });
});

module.exports = router;