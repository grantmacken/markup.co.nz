

document.addEventListener('DOMContentLoaded', function() {

    var xmlhttp = new XMLHttpRequest();
    var url = '/resources/images/svg/icons.svg'
    xmlhttp.open('GET', url, false);
    xmlhttp.send();

    //alert(new XMLSerializer().serializeToString(xmlhttp.responseXML));
    document.body.insertBefore(xmlhttp.responseXML.firstChild, document.body.firstChild)

});
