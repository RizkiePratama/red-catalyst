function kick(cid, protocol) {
    if(protocol == "SRT") {
        window.alert("You Can't Kick SRT Connection!")
    } else {    
        fetch(document.location.origin + '/srs/api/v1/clients/' + cid, { method: 'DELETE' }).then(function (response) {
            if (response.ok) {
                console.log(response.json());
            }
        });
    }
}


function srs_stats(app_name) {
    var streams, clients = [];

    var streams,clients;
    fetch(document.location.origin + '/srs/api/v1/streams/').then(function (response) {
	if (response.ok) {
		return response.json();
	} else {
		return Promise.reject(response);
	}
    }).then(function (res_data) {
        streams = res_data.streams;
        return fetch(document.location.origin + '/srs/api/v1/clients/');
    }).then(function (response) {
        if (response.ok) {
            return response.json();
        } else {
            return Promise.reject(response);
        }
    }).then(function (res_data) {
        clients = res_data.clients;
        
        var tBody = "";
        streams.forEach(function(stream, i) {
            if(stream.app != app_name ) return; 

            if(stream.publish.active) {
                // Calculate Duration
                var alive_time;
                var protocol;
                if(typeof clients[i] === 'undefined') {
                    alive_time = 0;
                    protocol = "N/A"
                } else {
                    alive_time = clients[i].alive;
                    protocol = clients[i].tcUrl.includes("127.0.0.1") ? "SRT" : "RTMP";
                }
                duration = new Date(alive_time * 1000);
                var duration_str = duration.toISOString().substr(11, 8);
                
                tBody += '<tr>';
                tBody += '<td class="has-text-centered"><a href="/input/live/' + stream.name + '">' + stream.name + '</a></td>';
                tBody += '<td class="has-text-centered">' + protocol + '</td>';
            
                if(stream.video == null) {
                    stream.video = {   
                        codec: null,
                        profile: null,
                        width: null,
                        height: null,
                        level: null
                    };
                }

                tBody += '<td class="has-text-centered">' + stream.video.codec + ' ' +  stream.video.profile +  ' ' +  stream.video.level + '</td>';
                tBody += '<td class="has-text-centered">' + stream.video.width + 'x' +  stream.video.height  + '</td>';

                if(stream.audio == null) {
                    stream.audio = {   
                        codec: null,
                        sample_rate: null
                    };
                }
                tBody += '<td class="has-text-centered">' + stream.audio.codec + '</td>';
                tBody += '<td class="has-text-centered">' + parseInt(stream.audio.sample_rate) / 1000.0 + ' kHz</td>';

                tBody += '<td class="has-text-centered">' + stream.kbps.recv_30s + ' Kbps </td>';
                tBody += '<td class="has-text-centered">' + duration_str + '</td>';
                tBody += '<td class="has-text-centered"><a onclick=kick(\''+stream.publish.cid+'\',\''+protocol+'\')>Kick</a></td>'
                tBody += '</tr>';
            }
        });

        document.getElementById("rtmp-input-body").innerHTML = tBody;
    }).catch(function (error) {
        console.warn(error);
    });
}

app_name = window.location.pathname.split('/').pop();
srs_stats(app_name);
setInterval(function(){
    srs_stats(app_name);
}, 5000);
//setInterval(updateThumb, 2000);