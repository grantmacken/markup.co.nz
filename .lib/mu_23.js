

const  PR_CREATE_FILE = 0x08;
const  PR_WRONLY = 0x02;
const  PR_APPEND = 0x10;
const  PR_TRUNCATE = 0x20;


var cLOCAL_FILE = Components.classes["@mozilla.org/file/local;1"]
	.createInstance(Components.interfaces.nsILocalFile);

var cFILE_OUTPUT_STREAM = Components.classes["@mozilla.org/network/file-output-stream;1"]
	.createInstance(Components.interfaces.nsIFileOutputStream);

var cFILE_INPUT_STREAM = Components.classes["@mozilla.org/network/file-input-stream;1"].
              createInstance(Components.interfaces.nsIFileInputStream);

var cCONVERTER_INPUT_STREAM = Components.classes["@mozilla.org/intl/converter-input-stream;1"].
              createInstance(Components.interfaces.nsIConverterInputStream);

var cRUN_SERVICE = Components.classes["@activestate.com/koRunService;1"].
createInstance(Components.interfaces.koIRunService);


var getBrowser = function() {
    browserView = null
    var view2 = document.getElementById('view-2');
    var docViews = view2.getDocumentViews(true);
      //co('views in View 2: ' + docViews.length)
    if (docViews.length) {
	for (var i in docViews) {
	    thisView = docViews[i]
	    if (thisView.getAttribute("type") == 'browser') {
		browserView = thisView.browser
	    }
	}
    }
    return browserView
}


var writeXmlToFile = function( oData ) {
    return new RSVP.Promise(function(resolve, reject) {
    try {
	let filePath = oData.filePath;
	let xDoc = oData.xDoc;
	let xmlSERIALIZER = new XMLSerializer();;
	cLOCAL_FILE.initWithPath( filePath );
	cFILE_OUTPUT_STREAM.init( cLOCAL_FILE, PR_CREATE_FILE | PR_WRONLY | PR_TRUNCATE, -1, 0 );
	xmlSERIALIZER.serializeToStream( xDoc, cFILE_OUTPUT_STREAM, "" );
	cFILE_OUTPUT_STREAM.close();
	resolve( filePath );
    } catch (e) {
	cFILE_OUTPUT_STREAM.close();
	reject(e)
    }
   });
}

var getCmdOutput = function( obj ) {
  return new RSVP.Promise(function(resolve, reject) {
       try {
	var process = cRUN_SERVICE.RunAndNotify(obj.cmd, obj.DIR_PROJECT, '', '');
	var retval = process.wait(-1); /* wait till the process is done */
	stdOut = process.getStdout()
	if (stdOut) {
	    var str = stdOut.split('\n')[stdOut.split('\n').length -2]
	    if ( str != '') {
		resolve( str );
	    } else{throw 'Could NOT parse stdOut'}
	}
	else{throw 'No stdOut from getCmdOutput'}
    } catch (e) {
	reject(e)
    }
   });
}


var xpathLookFor = function(doc, node, nsResolver, xpath, message) {
    return new RSVP.Promise(function(resolve, reject) {
	try {
	    var evalulated = doc.evaluate(xpath, node, nsResolver, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
	    if (evalulated.singleNodeValue) {
		resolve(evalulated.singleNodeValue, message )
	    } else {
		throw ( 'NO NODE: can not find ' + message )
	    }
	} catch (e) {
	    reject(e)
	}
    });
}





//
//var xmlFileToDOM = function(filePath) {
//    return new RSVP.Promise(function(resolve, reject) {
//    try {
//	co('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX')
//	var data = "";
//	co(filePath)
//	//LOCAL_FILE.initWithPath(filePath);
//	LOCAL_FILE.initWithPath('/home/grant/projects/markup.co.nz/data/authors/ndfOM68BTLvHla7UeuzkSQ.xml');
//	FILE_INPUT_STREAM .init(LOCAL_FILE, -1, 0, 0);
//	CONVERTER_INPUT_STREAM.init(FILE_INPUT_STREAM, "UTF-8", 0, 0); // you can use another encoding here if you wish
//	//XMLSERIALIZER.serializeToStream(xmlDoc, FILE_OUTPUT_STREAM, "");
//	let (str = {}) {
//	let read = 0;
//	    do {
//	      read = CONVERTER_INPUT_STREAM.readString(0xffffffff, str); // read as much as we can and put it in str.value
//	      data += str.value;
//	    } while (read != 0);
//	  }
//
//	co(data)
//	co('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX')
//	FILE_INPUT_STREAM.close();
//	resolve(data);
//    } catch (e) {
//	FILE_INPUT_STREAM.close();
//	reject(e)
//    }
//   });
//}
