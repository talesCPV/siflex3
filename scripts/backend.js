/*  DATABASE  */
function queryDB(params,cod){
    let access = -1
    try{
        access = main_data.dashboard.data.access
    }catch{
        access = -1
    }

    const hash = localStorage.getItem('hash') == undefined ? 0 : localStorage.getItem('hash')
    const data = new URLSearchParams()
        data.append("access", access)
        data.append("hash", hash)
        data.append("cod", cod)
        data.append("params", JSON.stringify(params))

    const myRequest = new Request("backend/query_db.php",{
        method : "POST",
        body : data
    });

    return new Promise((resolve,reject) =>{
        fetch(myRequest)
        .then(function (response){
            if (response.status === 200) { 
                resolve(response.text())        
            } else { 
                reject(new Error("Houve algum erro na comunicação com o servidor"));
            } 
        });
    });      
}


function backFunc(params,cod){
    const data = new URLSearchParams();        
        data.append("cod", cod);
        data.append("params", JSON.stringify(params));        

    const myRequest = new Request("backend/functions.php",{
        method : "POST",
        body : data
    });

    return new Promise((resolve,reject) =>{
        fetch(myRequest)
        .then(function (response){
            if (response.status === 200) { 
                resolve(response.text());                    
            } else { 
                reject(new Error("Houve algum erro na comunicação com o servidor"));                    
            } 
        });
    });      
}

function getConfig(field){
    const data = new URLSearchParams();        
        data.append("user", localStorage.getItem('id_user'));
        data.append("field", field);
        data.append("file",'config.json');
    const myRequest = new Request("backend/getConfig.php",{
        method : "POST",
        body : data
    });

    return new Promise((resolve,reject) =>{
        fetch(myRequest)
        .then(function (response){
            if (response.status === 200) {                 
                resolve(response.text());                    
            } else { 
                reject(new Error("Houve algum erro na comunicação com o servidor"));                    
            } 
        });
    }); 
}

function setConfig(field,value){
    const data = new URLSearchParams();        
    data.append("user", localStorage.getItem('id_user'));
    data.append("field", field);
    data.append("file",'config.json');
    data.append("value", value);
    const myRequest = new Request("backend/setConfig.php",{
        method : "POST",
        body : data
    });

    return new Promise((resolve,reject) =>{
        fetch(myRequest)
        .then(function (response){
            if (response.status === 200) {                 
                resolve(response.text());                    
            } else { 
                reject(new Error("Houve algum erro na comunicação com o servidor"));                    
            } 
        });
    }); 
}

function uploadImage(fileID,path,filename){

    const up_data = new FormData();        
        up_data.append("up_file",  document.getElementById(fileID).files[0]);
        up_data.append("path", path);
        up_data.append("filename", filename);

    const myRequest = new Request("backend/upload.php",{
        method : "POST",
        body : up_data
    });

    const myPromisse = new Promise((resolve,reject) =>{
        fetch(myRequest)
        .then(function (response){
            if (response.status === 200) { 
                resolve(response.text());             
            } else { 
                reject(new Error("Houve algum erro na comunicação com o servidor"));                    
            } 
        });
    }); 

    return myPromisse
}

function listNF(path,ext='txt'){

    const data = new URLSearchParams()
        data.append("dir",path)
        data.append("ext",ext)
    const myRequest = new Request("backend/show_dir.php",{
        method : "POST",
        body : data
    })
    const myPromisse = new Promise((resolve,reject) =>{
        fetch(myRequest)
        .then(function (response){
            if (response.status === 200) {
                resolve(response.text())
            } else {
                reject(new Error("Houve algum erro na comunicação com o servidor"))
            }
        })
    })
    myPromisse.then((txt)=>{
        const list = JSON.parse(txt)
        const sel = document.querySelector(`#${ext}Files`)
        sel.innerHTML=''
        for(let i=list.length-1; i>1;  i--){
            sel.innerHTML += `<option value="${list[i]}">${list[i]}</option>`
        }
    })
}

function getFile(path){
    const data = new URLSearchParams();        
        data.append("path", path);
    const myRequest = new Request("backend/loadFile.php",{
        method : "POST",
        body : data
    });

    return new Promise((resolve,reject) =>{
        fetch(myRequest)
        .then(function (response){
            if (response.status === 200) {                 
                resolve(response.text());                    
            } else { 
                reject(new Error("Houve algum erro na comunicação com o servidor"));                    
            } 
        });
    }); 
}

function NFeConf(file){
    file = JSON.stringify(file)
    saveFile(file,path='/../../NF/NFe/json/NFe.json')
}

function NFsConf(file){
    saveFile(file,path='/../../NF/NFe/json/NFs.json')
}

function saveFile(file,path){
    const data = new URLSearchParams();
        data.append("file", JSON.stringify(file));
        data.append("path", path);
    const myRequest = new Request("backend/saveFile.php",{
        method : "POST",
        body : data
    });

    return new Promise((resolve,reject) =>{
        fetch(myRequest)
        .then(function (response){
            if (response.status === 200) {                 
                resolve(response.text());                    
            } else { 
                reject(new Error("Houve algum erro na comunicação com o servidor"));                    
            } 
        });
    }); 

}

function uploadNFe(txt, filename){

    saveFile(txt,path=`/../../NF/NFe/txt/${filename}.txt`).then(()=>{
        alert('NFe exportada com sucesso!!')
        listNF('../NF/NFe/txt')
        if (confirm(`Deseja lançar od boletos?`)) {
            const data = main_data.fisc_nfe.data.config
            for(let i=0; i<data.Y07.length; i++){
                const pgto = new Object            
                pgto.sac = data.E.xNome.split(' ')[0]
                pgto.nf = data.B.nNF
                pgto.ref =  (i+1).toString().padStart(2,"0") +'/'+ (data.Y07.length).toString().padStart(2,"0")
                pgto.venc = data.Y07[i].Y07.date
                pgto.val = data.Y07[i].Y07.valor
                addBoleto(pgto)
            }
        }
        document.querySelector('#tab-export').click()
    })    
}

function uploadNFs(txt, filename){

    saveFile(txt,path=`/../../NF/NFs/txt/${filename}.txt`).then(()=>{
        alert('NFs exportada com sucesso!!')
        listNF('../NF/NFs/txt')
        if (confirm(`Deseja lançar od boletos?`)) {
/*
            for(let i=0; i<pageData.NFs.fatura.length; i++){
                addBoleto(pageData.NFs.fatura[i])
            }
*/
        }
        document.querySelector('#tab-export').click()
    })
}

function uploadFile(file,path,filename){

    const up_data = new FormData()
    up_data.append("up_file",  file);
    up_data.append("path", path);
    up_data.append("filename", filename);

    const myRequest = new Request("backend/upload.php",{
        method : "POST",
        body : up_data
    })

    const myPromisse = new Promise((resolve,reject) =>{
        fetch(myRequest)
        .then(function (response){
            if (response.status === 200) { 
                resolve(response.text());             
            } else { 
                reject(new Error("Houve algum erro na comunicação com o servidor"))
            } 
        });
    }); 

    return myPromisse
}