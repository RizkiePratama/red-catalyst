document.addEventListener('DOMContentLoaded', (event) => {
    // Dashboard Modal
    var btn = document.querySelector('#modal-open');
    var modalDlg = document.querySelector('#modal-window');
    var modalCloseBtn = document.querySelector('#modal-close');

    btn.addEventListener('click', function(){
    modalDlg.classList.add('is-active');
    });

    modalCloseBtn.addEventListener('click', function(){
    modalDlg.classList.remove('is-active');
    });
})

function openOverlayPreview(id) {
    var modalDlg = document.querySelector('#modal-window');
    var img = document.getElementById('overlay-preview-img')
    fetch(document.location.origin + '/api/v1/overlay/' + id).then(function (response) {
    if (response.ok) {
        return response.json();
    } else {
        console.log("not ok");
        return Promise.reject(response);
    }
    }).then(function (res_data) {
        setOverlayPreviewImage(res_data, img, id);
        modalDlg.classList.add('is-active');
    })
}

function setOverlayPreviewImage(res_data, img, id) {
    overlay_path = document.location.origin + '/' + res_data.path;
    img.src = overlay_path;
}