function target_stream_checker() {
    fetch(document.location.origin + '/api/v1/stream/checker').then(function (response) {
        if (response.ok) {
            return response.json();
        } else {
            return Promise.reject(response);
        }
    });
}

setInterval(function(){
    target_stream_checker();
}, 5000);