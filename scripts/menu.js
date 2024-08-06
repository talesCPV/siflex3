function closeMenu(){
    try{
        document.getElementById('sidebar').classList.remove('open-sidebar');
        const ckb = document.querySelector('#sidebar_content').querySelectorAll('input[type=checkbox]')
        for(let i=0; i<ckb.length; i++){
            ckb[i].checked = 0
        }
    }catch{null}
}


function openMenu(){

    var drop = 0
    const data = new URLSearchParams();        
        data.append("hash", localStorage.getItem('hash'));
    const myRequest = new Request("backend/openMenu.php",{
        method : "POST",
        body : data
    });

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

    myPromisse.then((resolve)=>{
        try{
            const menu_data = JSON.parse(resolve)
            const menu = document.querySelector('#side_items')
            menu.innerHTML = ''//usr_menu
            pushMenu(menu, menu_data)
            checkUserMail()
            addShortcut()
            document.querySelector('#user-name').innerHTML = localStorage.getItem('nome')
            document.querySelector('#user-email').innerHTML = localStorage.getItem('email')
        }catch{            

            localStorage.clear()
            this.location.reload(true)
        }
    })

    function pushMenu(menu, obj){
        for( let i=0; i<obj.length; i++){      
            main_data.dashboard.data.access = obj[i].access 
            const li = document.createElement('li')
            li.className = 'side-item'
            const label = document.createElement('label')

            
            if(obj[i].hasOwnProperty('class')){
                li.classList.add(obj[i].class)
            }
          
            if (obj[i].itens.length > 0 ){
                const lbl = document.createElement('label')
                lbl.htmlFor = `drop-${drop}`
                lbl.classList = 'toggle'
                
                const icon = document.createElement('span')
                icon.className = `mdi ${obj[i].icone}`
                lbl.appendChild(icon)

                const desc = document.createElement('div')
                desc.className = 'item-description'

                const name_mod = document.createElement('span')
                name_mod.innerHTML = obj[i].modulo
                desc.appendChild(name_mod)

                const arrow = document.createElement('span')
                arrow.className = 'mdi mdi-arrow-right-thick item-description'
                desc.appendChild(arrow)

                lbl.appendChild(desc)


                li.appendChild(lbl)
                
                if(obj[i].modulo == '@username'){
                    name_mod.innerHTML = 'Configurações'
                    icon.className = `mdi mdi-account-circle-outline`
                }
                
                const ckb = document.createElement('input')
                ckb.type = 'checkbox';
                ckb.id = `drop-${drop}`
                drop++
                li.appendChild(ckb)

                if(obj[i].itens.length > 0){
                    const ul = document.createElement('ul')  
                    ul.className = 'sub-menu'
                    for(let j=0; j<obj[i].itens.length; j++){
                        pushMenu(ul,obj[i].itens[j])
                    }                                         
                    li.appendChild(ul)
                }
            }else{

                const lbl = document.createElement('label')

                const icon = document.createElement('span')
                icon.className = `mdi ${obj[i].icone}`
                lbl.appendChild(icon)
               
                const desc = document.createElement('span')
                desc.className = 'item-description'
                desc.innerHTML = obj[i].modulo
                lbl.appendChild(desc)

                lbl.addEventListener('click',()=>{
                    main_data.dashboard.data.access = obj[i].access
                    openHTML(obj[i].link,obj[i].janela,obj[i].label,{},obj[i].width)
                    closeMenu()
                })    
                lbl.addEventListener('contextmenu',(e)=>{
                    e.preventDefault()
                    if(confirm('Criar atalho na área de trabalho?')){
                        const myConfig = getConfig('shortcut')
                        myConfig.then((response)=>{
                            const json = response != '' ? JSON.parse(JSON.parse(response)) : []
                            const shortcut = new Object
                            shortcut.name = obj[i].modulo 
                            shortcut.link = obj[i].link
                            shortcut.icone = obj[i].icone
                            shortcut.janela = obj[i].janela
                            shortcut.label = obj[i].label
                            shortcut.width = obj[i].width
                            shortcut.x = 100
                            shortcut.y = 100
                            json.push(shortcut)
                            setConfig('shortcut' , JSON.stringify(json))
                            .then((resolve)=>{
                                addShortcut()
                                main_data.dashboard.data.shortcut = json.shortcut
                            })
                        })
//                        document.querySelector('#ckb-menu').checked = false
                    }
                })                        
                li.appendChild(lbl)                
            }
            menu.appendChild(li)
        }
    }
}

function addShortcut(){
    const myConfig = getConfig('shortcut')
    myConfig.then((response)=>{
        const main = document.querySelector('#main-screen')
        const icones = document.querySelectorAll('.icone')
        const json = response != '' ? JSON.parse(JSON.parse(response)) : new Object
        main_data.dashboard.data.shortcut = json
        
        for(let i=0; i<icones.length; i++){
            icones[i].remove()
        }

        for(let i=0; i<json.length; i++){
            const div = document.createElement('div')
            const label = document.createElement('p')
            div.className = 'icone'

            label.innerHTML= json[i].name
            div.appendChild(label)

            const icon = document.createElement('span')
            icon.className = `mdi ${json[i].icone}`
            div.appendChild(icon)

            div.addEventListener('mousedown',(e)=>{
            
                const x = parseInt(div.style.left)
                const y = parseInt(div.style.top)
                const pos = [x,y,e.clientX, e.clientY]
                document.onmousemove = (e,p=pos)=>{
                    e.preventDefault();                  
                    const left = p[0]-p[2]+e.clientX
                    const top = p[1]-p[3]+e.clientY
                    left >= 82 ? div.style.left =  left+'px' : null
                    top >= 0 ? div.style.top = top +'px' : null
                }
        
                document.onmouseup = (e,p=pos)=>{
                    e.preventDefault()
                    const sc = main_data.dashboard.data.shortcut
                    const move = (e.clientX != p[2] || e.clientY != p[3])
                    for(let j=0; j<sc.length; j++){
                        if(sc[j].link == json[i].link){
                            sc[i].x = p[0]-p[2]+e.clientX
                            sc[i].y = p[1]-p[3]+e.clientY                      
                            setConfig('shortcut' , JSON.stringify(sc))
                        }
                    }

                    /* icon click */
                    if(!move && e.button == 0){
                        main_data.dashboard.data.access = json[i].access 
                        openHTML(json[i].link,json[i].janela,json[i].label,{},json[i].width)
                    }

                    document.onmouseup = null;
                    document.onmousemove = null;
                }
            
            })           

            div.addEventListener('contextmenu',(e)=>{
                e.preventDefault()
            
                const tbl = []
                const obj = new Object
                obj.label = 'Deletar Atalho?'
                obj.link = ()=>{
                    const sc = main_data.dashboard.data.shortcut
                    for(let j=0; j<sc.length; j++){
                        if(sc[j].link == json[i].link){
                            sc.splice(i,1)
                            setConfig('shortcut' , JSON.stringify(sc))
                            addShortcut()
                        }
                    }
                    div.style.left = '0'
                }
                tbl.push(obj)
                menuContext(tbl,e)
            })

            div.style.left = json[i].x + 'px'
            div.style.top = json[i].y + 'px'
            main.appendChild(div)
        }
    })
}