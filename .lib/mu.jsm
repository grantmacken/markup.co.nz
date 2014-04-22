//https://developer.mozilla.org/en-US/docs/Mozilla/JavaScript_code_modules/

var EXPORTED_SYMBOLS = ['boo', 'foo', 'bar'];



function boo(str) {
    ko.widgets.getWidgetAsync("runoutput-desc-tabpanel", function(w) {
        wScimoz = w.contentDocument.getElementById("runoutput-scintilla").scimoz;
        var prevLength = wScimoz.length;
        var currNL = ["\r\n", "\n", "\r"][wScimoz.eOLMode];
        //str = ko.widgets.getWidgetInfo(w).label;
        var full_str = str + currNL;
        var full_str_byte_length = ko.stringutils.bytelength(full_str);
        var ro = wScimoz.readOnly;
        wScimoz.readOnly = false;
        wScimoz.appendText(full_str_byte_length, full_str);
    });
}


function foo() {
return 'foo';
}

var dummy = 'dummy is a string';

var bar = {
name: 'bar',
size: 3,
theDummy: dummy,
theLastVar: lastVar //when you import this jsm and try to get bar.theLastVar you will find that it is 'undefined', this is because 'lastVar' was not defined at the time this object was created
};

var lastVar = 'this is the last var its a string';
