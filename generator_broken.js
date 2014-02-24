
function generateCards(data){
	var $e = document.querySelector("main");
	var cards = data.split("\f");
	for(var i=0; i<cards.length; i++){
		var $card = document.createElement("div");
		$card.className = "card";
		var lines = cards[i].split("\n");
		for(var j=0,lwt=0; j<lines.length; j++){
			var l = lines[j];
			if(l.match(/^[\s\n\r]*$/))continue;
			
			var name = s;
			var cost = 0;
			var typeMajor = "N";
			
			switch(++lwt){
				case 1:
					//Name - Play Cost - Type Major
					if(l.indexOf("-")!==-1){
						var s = l.split("-");
						var name = s[0];
						var cost = parseFloat(s[1]);
						var typeMajor = s[2];
					}
					
					break;
				case 2:
					//Category
					
					break;
				case 3:
					//Attack / Defence
					
					break;
				case lines.length-1://last line
					//Type Tags
					
					break;
				default:
					$card.innerHTML += "<div class='unknown'>"+l+"</div>";
					break;
			}
			$card.innerHTML += 
				"<div class='header'>"
					+ "<span class='name'>"+name+"</span>"
					+ "<span class='cost'>"+cost+"</span>"
					+ "<span class='type-major'>"+typeMajor+"</span>"
				+ "</div>"
				+ "<div class='image'>"
					+ "<img class='img' title='das a pictr' src='images/"+name+".png'>"
					+ "<span class='cost'>"+cost+"</span>"
					+ "<span class='type-major'>"+typeMajor+"</span>"
				+ "</div>";
			
			console.debug(lwt, l);
		}
		$e.appendChild($card);
	}
}


var xhr = new XMLHttpRequest();

xhr.onerror = function(){
	alert("error");
};
xhr.onreadystatechange = function(){
	if(xhr.readyState === 4){
		if(xhr.status === 200 || xhr.status === 304){
			generateCards(xhr.responseText);
		}
	}
	
};
xhr.open("GET","cards.txt")
xhr.send();

