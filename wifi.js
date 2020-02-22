.pragma library

var avoid_request = false; // Doit-on envoyer la requête sachant le temps d'init de 10s
var debug = true;         // Doit-on afficher les informations sur le terminal serie
var sendInterval = 50;
var lastSent = new Date().getTime();




function zfill(number, size) {
  number = parseInt(number).toString();
  while (number.length < size) number = "0" + number;
  return number;
}




//params n'est pas défini
//la chaine doit etre composée intégralement
function sendWifiRequest(params) {

    var d = new Date();
    var n = d.getMilliseconds();
    var url = "" + params

    if(!avoid_request){
        var doc = new XMLHttpRequest();
        doc.open("GET", url);
        doc.send();
    }

    //Affichage d'information en console
    if (debug){
        console.log("Requesting " + url + " " + n)
    }
}
