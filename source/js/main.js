var verovio = require('verovio-dev');

let func = (arg) => {
    console.log(this);
};

func();

const node = 1;
console.log(node == true);