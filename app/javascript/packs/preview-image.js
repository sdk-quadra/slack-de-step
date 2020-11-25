document.addEventListener('DOMContentLoaded', () => {
    const preview = document.getElementById('preview')
    if (preview.src === '' || preview.src === null) {
        document.getElementById('deleteImg').style.display = 'none'
    }

    const messageImage = document.getElementById('message_image')
    messageImage.addEventListener('change', e => {
        const target = e.currentTarget
        const file = target.files[0]
        const reader  = new FileReader()
        reader.onloadend = function() {
            document.getElementById('preview').src = reader.result
            document.getElementById('deleteImg').style.display = 'block'
            document.getElementById('delete_check').checked = false
        }
        if (file) {
            reader.readAsDataURL(file)
        } else {
            document.getElementById('preview').src = ''
            document.getElementById('deleteImg').style.display = 'none'
        }
    })

    const deleteBtn = document.getElementById('deleteImg')
    deleteBtn.addEventListener('click', () => {
        const result = window.confirm('本当に削除しますか？')

        if (result) {
            document.getElementById('preview').src = ''
            document.getElementById('delete_check').checked = true
            document.getElementById('deleteImg').style.display = 'none'
        }
    })
})
