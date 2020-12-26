// 画像のプレビューをmodalで削除するjs
document.addEventListener('DOMContentLoaded', () => {
    const deleteImageConfirmation = document.getElementById("delete-image");
    if (deleteImageConfirmation) {
        deleteImageConfirmation.addEventListener("click", (e) => {
            document.getElementById("overlay-type").value = "delete-image";
            let overlayType = document.getElementById("overlay-type").value;
            let overlay = document.getElementById(`overlay-${overlayType}`);
            overlay.style.display = "block";
        })
    }

    const deleteExec = document.querySelectorAll(".modal__delete-image");
    deleteExec.forEach( d => {
        d.addEventListener("click", (e) => {
            document.getElementById("preview").src = "";
            document.getElementById("preview").classList.remove("message-form__preview-img");
            document.getElementById("delete-image").style.display = "none";
            document.getElementById("delete-image-check").checked = true;

            let overlayType = document.getElementById("overlay-type").value;
            let overlay = document.getElementById(`overlay-${overlayType}`);
            overlay.style.display = "none";
        })
    })
})
