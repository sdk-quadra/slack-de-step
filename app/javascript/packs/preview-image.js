// 画像のプレビューを表示するjs
document.addEventListener('DOMContentLoaded', () => {
    const preview = document.getElementById('preview')
    if (preview){
        if (preview.src === '' || preview.src === null) {
            document.getElementById('delete-image').style.display = 'none'
        }
    }

    const messageImage = document.getElementById('message_image')
    if (messageImage) {
        messageImage.addEventListener('change', e => {
            const target = e.currentTarget
            const file = target.files[0]
            const reader = new FileReader()
            reader.onloadend = function () {
                document.getElementById('preview').src = reader.result
                document.getElementById('preview').classList.add("message-form__preview-img")
                document.getElementById('delete-image').style.display = 'inline-block'
                document.getElementById('delete-image-check').checked = false
            }
            if (file) {
                reader.readAsDataURL(file)
            } else {
                // 画像選択画面でキャンセルした場合
                document.getElementById('preview').src = ''
                document.getElementById('preview').classList.remove("message-form__preview-img")
                document.getElementById('delete-image').style.display = 'none'
            }
        })
    }
})
