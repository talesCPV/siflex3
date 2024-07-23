/*  PROTOTYPES  */

/*  STRING  */
String.prototype.getHash = function(S){
    let weigth = 0
    let hash = ''
    let str = this.valueOf()

    function getRange(N){ // keeps caracters under ASCII 33 & 126
        while (N > 126 || N < 33){
            N -= 126
            N < 33 ? N += 33 : N
            N == 127 ? N++ : 0
        }
        return N
    }

    for (i = 0; i < str.length; i++) {
        weigth += str.charCodeAt(i) * 5
    }

    while(str.length < S){
        str += String.fromCharCode(str.length + 33)
    }

    for (i = 0; i < str.length; i++) {
        chr = getRange(weigth * str.charCodeAt(i))
        chr = chr===92 ? 168 : chr;
        chr = chr===34 ? 173 : chr;
        hash += String.fromCharCode(chr)  
    }
    
    return hash;
}

String.prototype.maxWidth = (N=0)=>{
    return ((N>0 && N<this.length) ? this.valueOf().substring(0,N) : this.valueOf())
}

String.prototype.money = function(D=2){

    const text = this.valueOf().replace(',','.')    
    const num = text.split('.')[0].replace(/\D/g, "")
    let after_dot
    try{
        after_dot = text.split('.')[1].replace(/\D/g, "").padEnd(2,0).substring(0,2)
    }catch{
        after_dot = '00'
    }

    let before_dot = ''
    for(let i=num.length-1; i>=0; i--){        
        before_dot = num[i] + before_dot        
        before_dot = (num.length-i)%3==0 && i>0 && i< num.length-1 ? '.'+before_dot : before_dot
    }
    return 'R$'+before_dot+'.'+after_dot
}

String.prototype.date = function(){
    const str = this.valueOf()
    return (str.substring(8,10)+'/'+str.substring(5,7)+'/'+str.substring(0,4))
}

String.prototype.time = function(){
    const str = this.valueOf()
    return (str.substring(11,16))
}

/* DATE */
Date.prototype.change = function(N=1){
    this.setDate(this.getDate()+N)
 }

Date.prototype.addHour = function(N=1){
    this.setHours(this.getHours()+N)
}
 
Date.prototype.addMin = function(N=1){
    this.setTime(this.getTime() + N*60000)
}

Date.prototype.iniMonth = function(){
    return this.overday(-1*(this,this.getDate())+1)
}

Date.prototype.finMonth = function(){
    return new Date(this.getFullYear() ,this.getMonth()+1,0).getFormatDate()
}

Date.prototype.getFormatDate = function(N=''){
    if(N==''){
        return (`${this.getFullYear()}-${(this.getMonth()+1).toString().padStart(2,'0')}-${this.getDate().toString().padStart(2,'0')}`)
    }else{
        this.change(N)
        const out = `${this.getFullYear()}-${(this.getMonth()+1).toString().padStart(2,'0')}-${this.getDate().toString().padStart(2,'0')}`
        this.change(-N)
        return out
    }
}

Date.prototype.getFormatBR = function(){
    return (`${this.getDate().toString().padStart(2,'0')}/${(this.getMonth()+1).toString().padStart(2,'0')}/${this.getFullYear()}`)
}

Date.prototype.overday = function(N){
    const tmw = new Date(this)
        tmw.change(N)
        return  tmw.getFormatDate()
}

Date.prototype.getFullHour = function(){
    return (`${this.getHours().toString().padStart(2,'0')}:${this.getMinutes().toString().padStart(2,'0')}:${this.getSeconds().toString().padStart(2,'0')}`)
}

Date.prototype.getFullTime = function(){
    return (`${this.getHours().toString().padStart(2,'0')}:${this.getMinutes().toString().padStart(2,'0')}`)
}

Date.prototype.getFullDate = function(){
    return `${this.getFormatBR()} ${this.getFullHour()}`
}

Date.prototype.getFullDateTime = function(){
    return `${this.getFormatDate()}T${this.getFullHour()}-03:00`
}

Date.prototype.getWeekDay = function(){
    const dia = ['Dom','Seg','Ter','Qua','Qui','Sex','Sab']
    return dia[this.getDay()]
}

Date.prototype.getCod = function(){
    return this.getFullYear().toString().substring(2,4) + (this.getMonth()+1).toString().padStart(2,'0') + this.getDate().toString().padStart(2,'0')
}

/* TABLE */
HTMLTableElement.prototype.plot = function(obj, fields,type='',file=false, mark=false , green=false){

    fields = fields.split(',')
    type = type=='' ? '' : type.split(',')
    const tr = document.createElement('tr')
    if(file && obj.path != null){
        tr.classList = 'path'
    }
    for(let i=0; i<fields.length; i++){
        const td = document.createElement('td')
        const arr = fields[i].split('|')
        if(arr.length > 1){
            td.classList = arr[1]
        }
        let html, op
    
        if(type.length > 0 && i<type.length){
            switch (type[i].substring(0,3)) {
                case 'int': // Numero Inteiro
                  html = parseInt(obj[arr[0]])
                  break;
                case 'flo': // Numero Decimal
                    html = obj[arr[0]] != null ? parseFloat(obj[arr[0]]).toFixed(2) : ''
                    break;

                case 'hor': // HORA 00:00
                    const a = obj[arr[0]] != null ? parseFloat(obj[arr[0]]).toFixed(2) : 0
                    html =  Math.floor(a).toString().padStart(2,0)+':'+ Math.round(parseFloat((a - Math.floor(a)) * 60)).toString().padStart(2,0)                    
                    break;

                case 'Upp': // Upper Case
                    html = obj[arr[0]] != null ? obj[arr[0]].toUpperCase().trim() : ''
                    break
                case 'str': // Valor literal
                    html = obj[arr[0]] != null ? obj[arr[0]].trim() : ''
                  break;
                case 'dat': // Formato de Data dia/mes/ano
                    html = obj[arr[0]] != null ? obj[arr[0]].substring(8,10)+'/'+ obj[arr[0]].substring(5,7)+'/'+obj[arr[0]].substring(0,4) : ''
                    break                 
                case 'Low': // Lower Case
                    html = obj[arr[0]] != null ? obj[arr[0]].toLowerCase().trim() : ''
                    break;
                case 'R$.': // Formato Monetário R$0,00
                    if(parseFloat(obj[arr[0]]).toFixed(2) >=0 ){
                        html = obj[arr[0]] != null ? viewMoneyBR(parseFloat(obj[arr[0]]).toFixed(2)) : ''
                        green = true
                    }else{
                        html = obj[arr[0]] != null ? `(${viewMoneyBR(parseFloat(obj[arr[0]]).toFixed(2))})` : ''
                        green = false
                    }
                    break
                case '%..':
                    html = obj[arr[0]] != null ?parseFloat(obj[arr[0]]).toFixed(2)+'%' : ''   // parseFloat(obj[arr[0]]).toFixed(2) + %
                    break;             
    
                case 'cha': // Troca palavra escolhida por outra valor_original=valor_desejado
                    op = type[i].split(' ')
                    html = ''
                    for(let j=1; j<op.length; j++){
                        if((obj[arr[0]] == op[j].split('=')[0])||(j==op.length-1 && html=='')||obj[arr[0]] == null ){
                            html = op[j].split('=')[1] == '**' ? obj[arr[0]] : op[j].split('=')[1]
                        }
                    }
                    break; 
                case 'ico': // Troca palavra escolhida por outra valor_original=valor_desejado
                    op = type[i].split(' ')
                    html = ''
                    for(let j=1; j<op.length; j++){
                        if((obj[arr[0]] == op[j].split('=')[0])||(j==op.length-1 && html=='')||obj[arr[0]] == null ){
                            html =  `<span class="mdi ${op[j].split('=')[1] == '**' ? obj[arr[0]] : op[j].split('=')[1]}"></span>`
                        }
                    }
                    break;                     
                case 'ckb': // insere checkbox                      
                    html = `<input type="checkbox" id="tblCkb_${this.rows.length-1}" class="tbl-ckb" ${parseInt(obj[arr[0]])? '' : 'checked'}>`
                    break;
                case 'cnp': // Formata CNPJ
                    html = obj[arr[0]] != null ? getCNPJ(obj[arr[0]].trim()) : ''
                    break;
                case 'ie.': // Formata Insc. Estadual
                    html = obj[arr[0]] != null ? getIE(obj[arr[0]].trim()) : ''
                    break;                    
                case 'btn': // Adiciona Botão
                    op = type[i].split(' ')
                    op = op.length > 1 ? op[1] : 'OK'                
                    html = `<button id="btn_${this.rows.length-1}" class="tbl-btn">${op}</button>`
                    break;
                case 'let':                            
                    html = arr[0]
                    break;                      
                default:
                  html = obj[arr[0]] != null ? obj[arr[0]] :''
            }            
        }else{
            html = obj[fields[i].split('|')[0]]
        }
        td.innerHTML = html
        tr.appendChild(td)
    }
    tr.data = obj
    if(mark){
        tr.classList.add(green ? 'green' : 'red')
    }
    this.appendChild(tr)
}

HTMLTableElement.prototype.head = function(hd){
    this.innerHTML = ''
    hd = hd.split(',')
    const tr = document.createElement('tr')
    for(let i=0; i<hd.length; i++){
        const th = document.createElement('th')
        const arr = hd[i].split('|')
        if(arr.length > 1){
            th.classList = arr[1]
        }
        if(arr[0] == 'ckb-all'){
            const all = document.createElement('input')
            all.type = 'checkbox'
            all.addEventListener('click',(e)=>{
                var nodes = Array.prototype.slice.call(e.target.parentNode.parentNode.children);
                const index = nodes.indexOf(e.target.parentNode)
                for(let i=1; i<this.rows.length; i++){
                    try{
                        this.rows[i].cells[index].children[index].checked = all.checked
                    }catch{
                        console.error('Erro controlado, vai ficar assim mesmo!');
                    }
                }
            })
            th.appendChild(all)
        }else{
            th.innerHTML = arr[0]
        }
        tr.appendChild(th)
    }
    this.appendChild(tr)
}
