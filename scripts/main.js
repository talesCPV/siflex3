
/* VARIABLES */

var main_data = new Object
var today = new Date()
var meses = ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro']
var semana = ['Dom','Seg','Ter','Qua','Qui','Sex','Sab']
var nfe_rules = 0
getFile('/../config/NFe_rules.json').then((json)=>{
    nfe_rules = JSON.parse(json)
})
var nfs_rules = {}
getFile('/../config/NFs_rules.json').then((json)=>{
    nfs_rules = JSON.parse(json)
})

/*  FUNCTIONS  */

function forceHTTPS(){
    location.protocol !== 'https:' ? location.replace(`https:${location.href.substring(location.protocol.length)}`) : null
}

/*  ABAS */

function pictab(e){
    const tab = e.id
    const content = document.querySelectorAll(".tab");
    for (let i = 0; i < content.length; i++) {
        const sel_tab = document.querySelector('#tab-'+content[i].id)

        if(content[i].id == tab.split('-')[1]){
            content[i].style.display = "block"
            sel_tab.classList.add("check-tab")
        }else{
            content[i].style.display = "none"
            sel_tab.classList.remove("check-tab")
        }
    }
}
 /* CHECK USER MAIL */

    function checkUserMail(){
        const params = new Object;
            params.hash = localStorage.getItem('hash')

        const myPromisse = queryDB(params,'USR-3');
        myPromisse.then((resolve)=>{
            const json = JSON.parse(resolve)[0]
            const unread = json.new_mail
            document.querySelector('#mail-badge-lbl').innerHTML = unread!='0' ? unread : ''
        })
    }

/* IMAGE */

function aspect_ratio(img,cvw=300, cvh=300){
    out = [0,0,cvw,cvh]
    w = img.width
    h = img.height
    
    if(w >= h){
        out[3] = cvh/(w/h)
        out[1] = (cvh - out[3]) / 2
    }else{
        out[2] = cvw/(h/w)
        out[0] = (cvw - out[2]) / 2
    }
    return out
}

function showFile(idFile='up_file',idCanvas='cnvImg'){
    const inputFile = document.getElementById(idFile)
    if (inputFile.files && inputFile.files[0]) {
        var reader = new FileReader();
        reader.onload = function (e) {            
            var ctx = document.getElementById(idCanvas)
            if (ctx.getContext) {
                ctx = ctx.getContext('2d');
                let preview = new Image();
                preview.onload = function () {
                    ar = aspect_ratio(preview,ctx.width,ctx.height) 
                    ctx.canvas.width = ar[2]
                    ctx.canvas.height = ar[3]
                    ctx.clearRect(0, 0, 300,300);
                    ctx.drawImage(preview, 0, 0,preview.width,preview.height,0,0,ar[2],ar[3]);
                };
                preview.src = e.target.result
            }
        }
        reader.readAsDataURL(inputFile.files[0]);
    }
}

function loadImg(filename, id='cnvImg',efect='normal') {
    var ctx = document.getElementById(id);     
    try{
        if (ctx.getContext) {
            ctx = ctx.getContext('2d');
            ctx.clearRect(0, 0, ctx.width, ctx.height);
            var img = new Image();
            img.onload = function () {
                ar = aspect_ratio(img,ctx.width,ctx.height)                
                ctx.canvas.width = ar[2]
                ctx.canvas.height = ar[3]
                ctx.globalCompositeOperation = efect
                ctx.drawImage(img, 0, 0,img.width,img.height,0,0,ar[2],ar[3]);
            };        
            img.src = filename+'?'+new Date().getTime()
        }
    }catch{
        console.error('Imagem não existe!')
    }

}

/* ARQUIVO DE LOG */

function setLog(line){
    const now = new Date
    line = line.normalize("NFD").replace(/[\u0300-\u036f]/g, "")
    const data = new URLSearchParams();        
        data.append("line",line);
        data.append("hash",localStorage.getItem('hash'));
    const myRequest = new Request("backend/setLog.php",{
        method : "POST",
        body : data
    })
    const myPromisse = new Promise((resolve,reject) =>{
        fetch(myRequest)
        .then(function (response){
            if (response.status === 200) { 
                resolve(response.text());             
            } else { 
                reject(new Error("Houve algum erro na comunicação com o servidor"));                    
            } 
        })
    })  
    myPromisse.then((txt)=>{

    })    
}

function logout(){
    if(confirm(`Encerrar login de ${localStorage.getItem('email')}?`)){
        localStorage.clear()
        this.location.reload(true)    
    }
}

/* FRM BUSCA */

function getVal(fds){
    const doc = document.querySelector(`.${fds}`)
    const sel = doc.querySelector('#cmbBusca')
    const field = sel.value
    const signal = sel.options[sel.selectedIndex].getAttribute('signal')
    let value = sel.options[sel.selectedIndex].hasAttribute('val') ? sel.options[sel.selectedIndex].getAttribute('val') : doc.querySelector('#edtBusca').value.trim()
        value = signal=='LIKE' ? `'%${value}%'` : signal=='IN' ? `(${value})` : value

    return [field,signal,value]
}