var searches = [];
function googleImage(query, callback){
	searches.push({query:query,callback:callback});
}

function generateCards(data){
	
	var $e = document.querySelector("main");
	
	var majorTypeNames = {
		"C": "Corporate",
		"O": "Occult",
		"M": "Military",
		"N": "Neutral",
		"F": "Fantastic",
	};
	
	var cards = data.split("\f");
	for(var i=0; i<cards.length; i++){
		
		if(cards[i].match(/^[\s\r\n]*$/)){
			continue;
		}
		
		var $container = document.createElement("div");
		$container.className = "container";
		var $card = document.createElement("div");
		$card.className = "card";
		var name = "UNKNOEN";
		var description = "";
		var cost = 0;
		var majorTypes = "N";
		var minorTypes = "";
		var attack = null;
		var defence = null;
		var category = null;
		
		var lines = cards[i].split("\n");
		for(var j=0,lwt=0; j<lines.length; j++){
			var l = lines[j].trim();
			if(l.match(/^[\s\n\r]*$/m))continue;
			
			
			switch(++lwt){
				case 1:
					//Name - Play Cost - Type Major
					if(l.indexOf(" - ")!==-1){
						var segs = l.split(" - ");
						name = segs[0];
						cost = parseFloat(segs[1]);
						majorTypes = segs[2];
					}else{
					//Name
						name = l;
					}
					
					break;
				case 2:
					//Category
					category = l;
					break;
				case 3:
					//Attack / Defence
					var m = l.match(/^(-?\d+) \/ (-?\d+)$/);
					if(m){
						attack = parseFloat(m[1]);
						defence = parseFloat(m[2]);
						break;
					}else{
						//don't break!
					}
				default:
					//Type Tags
					if(l.match(/^(([a-z]+, )*[a-z]+)$/)){
						minorTypes = l;
					}else if(l.match(/^["“](.*)["”]$/)){
						description += "<q>"+l.match(/^["“](.*)["”]$/)[1]+"</q>";
					}else{
						description += "<p>"
							+l.replace(/(\d+)m/g,function(m,m1){
								return "<span class='money'>"+m1+"<span class='m'></span></span>"
							})+"</p>";
						//console.log(lwt,l);
					}
					break;
			}
			
			
		}
		
		console.assert(category !== null, "no category");
		
		var majorTypesNames = "";
		for(var mti=0; mti<majorTypes.length; mti++){
			if(majorTypesNames != ""){
				majorTypesNames += " ";
			}
			majorTypesNames += majorTypeNames[majorTypes[mti]];
		}
		
		$card.innerHTML += ""
		//	+ "<div class='back'>"
		//		+ "this is the back lol"
		//	+ "</div>"
		//	+ "<div class='front'>"
				+ "<div class='header'>"
					+ "<span class='name'>"+name+"</span>"
					+ (isNaN(cost)?"":("<span class='cost'>"+cost+"<span class='m'></span></span>"))
				+ "</div>"
				+ "<div class='subheader'>"
					+ "<span class='category subthing' style='float: left'>"+category+"</span>"
					+ "<span class='type-major subthing' style='float: right'>"+majorTypesNames+"</span>"
				+ "</div>"
				+ "<div class='image'>"
					+ "<img class='img' title='das a pictr' src='images/"+name+".png'>"
				+ "</div>"
				+ "<div class='lower'>"
					+ ((attack!==null)?"<br><span class='yghfhsdf'>"+attack+"/"+defence+"</span>":"")
					+ "<div class='description'>"+description+"</div>"
					+ "<span class='id'>"+(i+1)+"</span>"
					+ "<div class='minor-types'>"+minorTypes+"</div>"
					/*+ (function(){
						var html = "<br>";
						for(var t=0;t<minorTypes.split(", ").length;t++){
							var type = minorTypes.split(", ")[t];
							html += "<a href='https://twitter.com/hashtag/"+type+"'>#"+type+"</a> ";
						}
						return html;
					})()*/
				+ "</div>"
		//	+ "</div>"
		;
		$card.querySelector("img").onerror = (function(name){
			return function(){
				var $img = this;
				$img.onerror = null;
				googleImage(name, function(src){
					$img.src = src;
				});
			};
		})(name);
		$card.style.backgroundPosition = Math.random()*5000+"px "+Math.random()*5000+"px";
		$container.appendChild($card);
		$e.appendChild($container);
		//$e.appendChild($card);
	}
}


var xhr = new XMLHttpRequest();

xhr.onerror = function(){
	alert("error");
};
xhr.onreadystatechange = function(){
	if(xhr.readyState === 4){
		generateCards(xhr.responseText);
	}
	
};
xhr.open("GET","cards.txt");
xhr.send();


google.load('search', '1');
var imageSearch;


function OnLoad() {

	imageSearch = new google.search.ImageSearch();
	imageSearch.setNoHtmlGeneration();
	imageSearch.setResultSetSize(1);
	function next(){
		var iid=setInterval(function(){
			if(searches.length){
				clearInterval(iid);
				imageSearch.setSearchCompleteCallback(this, function(){
					next();
					if(imageSearch.results, imageSearch.results[0]){
						searches[0].callback(imageSearch.results[0].tbUrl);
					}else{
						console.error("no resturlts: ",imageSearch.results,imageSearch);
					}
					searches.splice(0,1);
				}, null);
				imageSearch.execute(searches[0].query);
			}
		},100);
	}
	next();
	//causes an error
	//google.search.Search.getBranding('branding');
}
google.setOnLoadCallback(OnLoad);
