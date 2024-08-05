
async function openHTML(template='',where="content-screen",label="", data="",width='auto'){

    width = width == 'auto' ? (document.querySelector('body').offsetWidth - 160)+'px' : width+'px'


    if(template.trim() != "" && !main_data.hasOwnProperty(template.split('.')[0])){
        const page_name = template.split('.')[0]
        return await new Promise((resolve,reject) =>{
            fetch( "templates/"+template)
            .then( stream => stream.text())
            .then( text => {
                const temp = document.createElement('div');
                temp.innerHTML = text;
                let body = temp.getElementsByTagName('template')[0];
                let script = temp.getElementsByTagName('script')[0];

                if(body == undefined){
                    script = ''
                    body = document.createElement('div')
                    body.innerHTML = '<style>p{text-align : center;}</style> <p>Desculpe, este módulo ainda não foi implementado</p>'
                    body.style.color = '#FFFF00 !important'
                    where = 'pop-up'
                    label = 'ERRO 404!'
                }
                if(where == "pop-up"){
                    newModal(label,body.innerHTML,width,page_name)
                }else{
                    const cont = body.innerHTML.replace('<h1>', `<span id="close-screen" onclick="document.querySelector('#imgLogo').click()">&times;</span><h1>`)                    
                    document.getElementById(where).innerHTML = cont;                    
                }

                closeMenu()

                const new_obj = page_name

                main_data[new_obj] = new Object
                main_data[new_obj].data = typeof(data) != 'object' ? new Object : data
                main_data[new_obj].func = new Object

                eval(script.innerHTML);
                resolve = body
                 
            }); 
        }); 
    }
}

function newModal(title, content, width, id){

    const offset = 15
    const mod_main = document.querySelector('#main-screen')
    mod_main.scrollTo(0, 0)    
    const pages = mod_main.querySelectorAll('.modal-content')    
    const upper_page = new Object
    upper_page.i = 0
    for(let i=1; i<pages.length; i++){
        upper_page.i = parseInt(pages[upper_page.i].style.zIndex) < parseInt(pages[i].style.zIndex) ? i : upper_page.i
    }

    if(pages[upper_page.i] == undefined){
        upper_page.zIndex = mod_main.querySelectorAll('.modal-content').length +1          
        upper_page.top = 15
    }else{
        upper_page.zIndex = parseInt(pages[upper_page.i].style.zIndex)+1
        upper_page.top = parseInt(pages[upper_page.i].style.top)+15
    }
    upper_page.left = 100 + (document.querySelector('body').offsetWidth - 100 - parseInt(width))/2 + upper_page.zIndex*offset

    const mod_card = document.createElement('div')
        mod_card.classList = 'modal-content'
        mod_card.id = 'card-'+id        
        mod_card.style.position = 'absolute'
        mod_card.style.zIndex = upper_page.zIndex+1
        mod_card.style.margin = '0 auto'
        mod_card.style.width = width
        mod_card.style.top = upper_page.top+'px'
        mod_card.style.left = upper_page.left+'px'
        mod_card.style.overflow = 'auto'
        mod_card.addEventListener('mousedown',(e)=>{
            queueModal(id)
        })
        main_data.dashboard.up_page = mod_card.id

    const resize = document.createElement('div')
        resize.className = 'modal-resize'
        resize.addEventListener('mousedown',(e)=>{
            document.onmousemove = (e)=>{
                e.preventDefault();
                mod_card.style.width = (e.clientX - parseInt(mod_card.style.left) )+'px'
                mod_card.style.height = e.clientY - parseInt(mod_card.style.top)+'px' 
            }
    
            document.onmouseup = ()=>{
                document.onmouseup = null;
                document.onmousemove = null;
            }
        })

    mod_card.appendChild(resize)

    const mod_title = document.createElement('div')
    mod_title.className = 'modal-title'    
    mod_title.id = 'head-'+id

    mod_title.addEventListener('dblclick',()=>{
        if(mod_card.classList.contains('fullscreen')){
            mod_card.classList.remove('fullscreen')
        }else{
            mod_card.classList.add('fullscreen')
        }
    })

    mod_title.addEventListener('mousedown',(e)=>{
        const x = parseInt(mod_card.style.left)
        const y = parseInt(mod_card.style.top)
        const pos = [(x - e.clientX),(y - e.clientY)]

        document.onmousemove = (e,p=pos)=>{
            e.preventDefault();
            const left = p[0]+e.clientX
            const top = p[1]+e.clientY
            left >= 82 ? mod_card.style.left =  left+'px' : null
            top >= 0 ? mod_card.style.top = top +'px' : null
        }

        document.onmouseup = ()=>{
            document.onmouseup = null;
            document.onmousemove = null;
        }
    })

    const p = document.createElement('p')
    p.innerHTML = title
    mod_title.appendChild(p)

    const span = document.createElement('span')
    span.classList = 'close'
    span.innerHTML = '&times;'
    span.addEventListener('click',()=>{
        closeModal(id)
    })
    mod_title.appendChild(span)
    mod_card.appendChild(mod_title)

    const mod_content = document.createElement('div')
    mod_content.classList = 'modal-text'
    mod_content.innerHTML = content
    mod_card.appendChild(mod_content)

    mod_main.appendChild(mod_card)
    mod_main.style.display = "block"
    
    window.scrollTo(upper_page.left-82, upper_page.top);
}

function closeModal(id='all'){
    if(id=='all'){
        while(document.querySelectorAll('.modal-content').length > 0){
            delete main_data[mod_main.querySelectorAll('.modal-content')[0].id.split('-')[1]]
            document.querySelectorAll('.modal-content')[0].remove()    
        }
    }else{
        id = (id=='')? document.querySelectorAll('.modal-content').length-1 : 'card-'+ id    
        try{
            document.getElementById(id).remove()
            delete main_data[id.split('-')[1]]    
        }catch{ null }
    }
    main_data.dashboard.up_page = ''
}

function queueModal(id){
    const up = document.querySelector('#card-'+id)
    const pop = document.querySelectorAll('.modal-content')
    const up_index = parseInt(up.style.zIndex)
    let max = 0
    for(let i=0; i<pop.length; i++){
        const pop_index = parseInt(pop[i].style.zIndex)
        max = Math.max(max,pop_index)
        pop_index > up_index ? pop[i].style.zIndex = pop_index -1 : null        
    }
    up.style.zIndex = max
    main_data.dashboard.up_page = up.id
}

function menuContext(tbl,e){
    const mod_main = document.querySelector('#myModal')

    const backModal = document.createElement('div')
        backModal.classList = 'modal'
        backModal.id = 'context'
        backModal.style.zIndex = 200
        backModal.style.display = 'block'
        backModal.style.backgroundColor = 'unset'
        backModal.addEventListener('click',()=>{
            document.querySelector('#context').remove()
            mod_main.style.display = (document.querySelectorAll('.modal-content').length < 1) ? "none" : 'block'
        })

    const mod_card = document.createElement('div')
        mod_card.classList = 'modal-content'
        mod_card.id = 'card-context'       
        mod_card.style.position = 'absolute'
        mod_card.style.zIndex = 100
        mod_card.style.margin = '0 auto'
        mod_card.style.top = e.clientY+'px'
        mod_card.style.left = e.clientX+'px'
        mod_card.style.overflow = 'auto'

    const mod_content = document.createElement('table')
        mod_content.classList = 'modal-text'
        mod_content.style.left = '-7px'
        for(let i=0; i<tbl.length; i++){
            const tr = document.createElement('tr')
            const td = document.createElement('td')
            td.innerHTML = tbl[i].label
            td.addEventListener('click',()=>{
                tbl[i].link()
            })
            tr.appendChild(td)            
            mod_content.appendChild(tr)
        }
        mod_card.appendChild(mod_content)

    backModal.appendChild(mod_card)
    mod_main.appendChild(backModal)
    mod_main.style.display = "block"
}