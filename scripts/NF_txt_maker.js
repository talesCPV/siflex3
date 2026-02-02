
/***** NFe-VENDA ******/

class NFe{
    constructor(fds,rules){
        fds = fds.split(',')
        this.itens = new Array
        this.duplicatas = new Array
        this.rules = rules
        for(let i=0; i<fds.length; i++){
            this[fds[i]] = makeGroup(fds[i],this.rules)
        }
    }
}

NFe.prototype.addItem = function(data){  
    const keys = ['H','I','M','N','N02','O','O07','O10','Q','Q05','Q07','S','S05','S07']
    const out = new Object
    for(let i=0; i<keys.length; i++){
        out[keys[i]] = makeGroup(keys[i],this.rules)
        for (const key in out[keys[i]]) {
            if(data.hasOwnProperty(key)){
                out[keys[i]][key] = data[key].split('\r')[0].trim()
            }
        }               
    }

    this.itens.push(out)
    for(let i=0; i<this.itens.length;i++){
        this.itens[i].H.nItem = i+1                 
    }
}

NFe.prototype.addDupl = function(data){
    this.duplicatas = new Array
    for(let i=0; i<data.length; i++){
        const out = new Object
        out.Y07 = data[i]
        this.duplicatas.push(out)
    }
}

NFe.prototype.addCliente = function(data){

    const keys = ['E','E02','E05']
    for(let i=0; i<keys.length; i++){
        this[keys[i]] = makeGroup(keys[i],this.rules)
        for (const key in this[keys[i]]) {
            if(data.hasOwnProperty(key)){
                this[keys[i]][key] = data[key]
            }
        }
    }
    this.E.indIEDest = this.E.IE.trim() == '' ? 2 : 1
    this.E.IE = onlyNum(this.E.IE)
    this.E.IM = onlyNum(this.E.IM)
    this.E02.CNPJ = onlyNum(this.E02.CNPJ)    
    this.E05.fone = onlyNum(this.E05.fone)
    this.E05.CEP = onlyNum(this.E05.CEP)

    const out = IBGE_cMun(this.E05.xMun,this.E05.UF).then((response)=>{
        const json = JSON.parse(response)
        for(let i=0; i<json.length; i++){
            if(json[i].nome.trim().toLowerCase() == this.E05.xMun.trim().toLowerCase()){
                this.E05.xMun = json[i].nome
                this.E05.cMun = json[i].id
            }
        }
    })

    return out
}

NFe.prototype.import = function(obj){
    nfImport(obj,this)
}

NFe.prototype.geraChave = function(){

    this.B.cNF = Math.floor(Math.random() * 89999999 + 10000000)

    const today = new Date()
    const aamm = today.getFullYear().toString().substring(2)+today.getMonth().toString().padStart(2, '0')
    const chave = this.B.cUF + aamm + this.C02.CNPJ + this.B.mod + this.B.serie.padStart(3,0) +  this.B.nNF.padStart(9, '0') + this.B.tpEmis + this.B.cNF

    let dv = 0
    let mult = 2
    for(let i = 1; i < chave.length+1; i++){
        dv += (chave[chave.length - i] * mult)
        mult++

        if (mult > 9){
        mult = 2
        }
    }
    const resto = dv % 11
    dv = 11 - resto

    if(dv > 9){
        dv = 0
    }
    this.A.id = 'NFe'+chave+dv
}

NFe.prototype.geraTXT = function(){

    const NFe = Object.keys(this).sort().reduce(
        (obj, key) => { 
          obj[key] = this[key]; 
          return obj;
        }, 
        {}
      ); 

    let out = 'NOTAFISCAL|1|\n'

    function makeLine(obj,key){
        let line = key+'|'
        for(const obj_key in obj[key]){
            line += obj[key][obj_key] +'|'
        }
        return line + '\n'
    }

    function addItens(itens){
        let lines = ''
        for(let i=0; i<itens.length; i++){
            for (const item_key in itens[i]) {
                lines += makeLine(itens[i],item_key)
            }
        }
        return lines
    }

    for (const key in NFe) {
        if(typeof NFe[key] === 'object' && !Array.isArray(NFe[key]) && key!='rules'){                 
            if(key == 'W'){
                out += addItens(NFe.itens)
            }
            if(key == 'YA'){
                out += addItens(NFe.duplicatas)
            }
            out += makeLine(NFe,key)
        }
    }
    return out
}

NFe.prototype.saveRules = function(){
    const grupos = ['B','C','C02','C07']

    for(let i=0; i<grupos.length; i++){
        for (const key in this.rules[grupos[i]]) {
            if(this[grupos[i]].hasOwnProperty(key)){
                this.rules[grupos[i]][key].def = this[grupos[i]][key]
            }
        }
    }

    const file_rules = JSON.stringify(this.rules)
    saveFile(file_rules,'/../config/NFe_rules.json')
//    .then((resolve)=>{})
}

/***** NFs-SERVIÇO ******/

class NFs{
    constructor(rules){        
        this.rules = rules
        this.reloadXML()
/*        
        this.viewXML()     
        const day = new Date()    
        this.date = day.getDate().toString().padStart(2,0)+'/'+(day.getMonth()+1).toString().padStart(2,0)+'/'+day.getFullYear()
*/
    }
}

NFs.prototype.reloadXML = function(){
    this.makeXML(this.rules)
}

NFs.prototype.makeXML = function(arr,parent=null){

    for(let i=0; i<arr.length; i++){

        let item

        if(!this.hasOwnProperty('xmlDoc')){
            this.xmlDoc = document.implementation.createDocument(null, arr[i].tag, null)
            item = this.xmlDoc.documentElement
        }else{
            item = this.xmlDoc.createElement(arr[i].tag);
        }
            
        item.appendChild(this.xmlDoc.createTextNode(arr[i].valor.def))
    
        for(let j=0; j<arr[i].atrib.length; j++){
            item.setAttribute(arr[i].atrib[j].txt, arr[i].atrib[j].val);
        }
        
        if(arr[i].itens.length){
            this.makeXML(arr[i].itens,item)
        }        

        if(parent != null){
            parent.appendChild(item)
        }
    }
}

NFs.prototype.viewXML = function(){
    const serializer = new XMLSerializer();
    const xmlString = serializer.serializeToString(this.xmlDoc);
    return xmlString;
}

NFs.prototype.getRule = function(path){
    let arr = this.rules
    path = path.split('/')
    let out = {}
    function getObj(arr,key){
        for(let i=0; i<arr.length; i++){
            if(arr[i].tag == key){
                return arr[i]
            }
        }
        return 0
    }

    for(let i=0; i<path.length; i++){        
        const obj = getObj(arr,path[i])
        out = obj
        if(obj.itens){            
            arr = obj.itens
        }
    }
    return out
}

NFs.prototype.getValue = function(path){
    const out = this.getRule(path)
    return out ? out.valor.def : out
}

NFs.prototype.setValue = function(path,value){
    console.log(this.rules)
}

NFs.prototype.formatComa = function(val){
    val = ['NaN','undefined','null'].includes(val) ? '0,00' : val
    return val.replace('.',',')
}

NFs.prototype.import = function(grupo, obj){
    console.log(obj)
/*
    for (const grupo in obj) {
        if(NF.hasOwnProperty(grupo)){
            for (const campo in obj[grupo]){
                if(NF.rules[grupo].hasOwnProperty(campo)){
                    switch(NF.rules[grupo][campo].tipo){
                        case 'N':
                            obj[grupo][campo] = onlyNum(obj[grupo][campo])
                        break
                        case 'C':
                            obj[grupo][campo] = onlyAlpha(obj[grupo][campo])
                        break
                        default:
                            obj[grupo][campo] += campo == 'dhEmi' ? 'T07:00:00-03:00' : ''
                            obj[grupo][campo] += campo == 'dhSaiEnt' ? 'T16:00:00-03:00' : ''
                    }
                    NF[grupo][campo] =  obj[grupo][campo].trim()
                }
            }
        }
    }
*/

//    this.formatFields()
}

NFs.prototype.formatFields  = function(){
    this[10].AlqIssSN_IP    = this['CONF'].AlqIssSN
    this[20].VlNFS          = this.formatComa(this[20].VlNFS.toString())
    this[20].VlDed          = this.formatComa(this[20].VlDed.toString())
    this[20].VlBasCalc      = this.formatComa(this[20].VlBasCalc)
    this[20].AlqIss         = this['CONF'].AlqIssSN
    this[20].VlIss          = this.formatComa(this[20].VlIss)
    this[20].VlIssRet       = this.formatComa(this[20].VlIssRet)
    this[90].ValorNFS       = this.formatComa(this[90].ValorNFS)
    this[90].ValorISS       = this.formatComa(this[90].ValorISS)
    this[90].ValorDed       = this.formatComa(this[90].ValorDed)
    this[90].ValorIssRetTom = this.formatComa(this[90].ValorIssRetTom)
    this[90].ValTrib        = this.formatComa(this[90].ValTrib)
}

NFs.prototype.saveRules = function(){
    const grupos = ['10','20','30','90','CONF']

    for(let i=0; i<grupos.length; i++){
        if(this.hasOwnProperty(grupos[i])){
            for (const key in this.rules[grupos[i]]) {
                if(this[grupos[i]].hasOwnProperty(key)){
                    this.rules[grupos[i]][key].def = this[grupos[i]][key] == 'NaN' ? 0 : this[grupos[i]][key]
                }
            }
        }
    }

    const file_rules = JSON.stringify(this.rules)
    saveFile(file_rules,'/../config/NFs_rules.json')
//    .then((resolve)=>{})
}

NFs.prototype.export = function(keys){

    keys = keys.split(',')
    const NFs = Object.keys(this).sort().reduce(
        (obj, key) => {
          obj[key] = this[key]; 
          return obj;
        }, 
        {}
      ); 
    let out = ''

    function makeLine(obj,key){
        let line = key+'|'        
        for(const obj_key in obj[key]){
            line += obj[key][obj_key] +'|'
        }
        return line + '\n'
    }

    for (let i=0; i<keys.length; i++) {        
        if(typeof NFs[keys[i]] === 'object' && !Array.isArray(NFe[keys[i]]) && keys[i]!='rules'){
            out += makeLine(NFs,keys[i])
        }
    }
    return out
}

NFs.prototype.exportXML = function(nfs){

/*    
    const xml = document.implementation.createDocument(null, 'Sdt_ProcessarpsIn');

    xml.newTag('Sdt_ProcessarpsIn','Login')
    xml.newTag('Login','CodigoUsuario','609612c6-c072-4818-8e89-5490482d7f8545av18ap9305acac000-ed12-o1i')
    xml.newTag('Login','CodigoContribuinte','54e52fdb-c30b-4236-9565-b9ef226086f012av10ap0050acac398-ed15-o4i')

    xml.newTag('Sdt_ProcessarpsIn','SDTRPS')
    xml.setAtr('SDTRPS','xmlns','NFe')

    xml.newTag('SDTRPS','Ano',nfs['10'].DtFin.substr(-4))
    xml.newTag('SDTRPS','Mes',nfs['10'].DtFin.substr(-7,2))
    xml.newTag('SDTRPS','CPFCNPJ',nfs['10'].CpfCnpj)
    xml.newTag('SDTRPS','DTIni',nfs['10'].DtIni)
    xml.newTag('SDTRPS','DTFin',nfs['10'].DtFin)
    xml.newTag('SDTRPS','TipoTrib',nfs['10'].TipoTrib)
    xml.newTag('SDTRPS','DtAdeSN')
    xml.newTag('SDTRPS','AlqIssSN_IP')
    xml.newTag('SDTRPS','RegApTribSN')
    xml.newTag('SDTRPS','TribTpSusp')
    xml.newTag('SDTRPS','TribProcSusp')
    xml.newTag('SDTRPS','Versao',nfs['10'].Versao)
    xml.newTag('SDTRPS','Reg20')
    xml.newTag('Reg20','Reg20Item')
    xml.newTag('Reg20Item','TipoNFS',nfs['20'].TipoNFS)
    xml.newTag('Reg20Item','NumRps',nfs['20'].NumRPS)
    xml.newTag('Reg20Item','SerRps',nfs['20'].SerRPS)
    xml.newTag('Reg20Item','DtEmi',nfs['20'].DtEmi)
    xml.newTag('Reg20Item','RetFonte',nfs['20'].RetFonte)
    xml.newTag('Reg20Item','CodSrv',nfs['20'].CodSrv)
    xml.newTag('Reg20Item','DiscrSrv',nfs['20'].DiscrSrv)
    xml.newTag('Reg20Item','VlNFS',nfs['20'].VlNFS)
    xml.newTag('Reg20Item','VlDed',nfs['20'].VlDed)
    xml.newTag('Reg20Item','DiscrDed',nfs['20'].DiscrDed)
    xml.newTag('Reg20Item','VlBasCalc',nfs['20'].VlBasCalc)
    xml.newTag('Reg20Item','AlqIss',nfs['20'].AlqIss)
    xml.newTag('Reg20Item','VlIss',nfs['20'].VlIss)
    xml.newTag('Reg20Item','VlIssRet',nfs['20'].VlIssRet)
    xml.newTag('Reg20Item','CpfCnpTom',nfs['20'].CpfCnpjTom)
    xml.newTag('Reg20Item','RazSocTom',nfs['20'].RazSocTom)
    xml.newTag('Reg20Item','TipoLogtom',nfs['20'].TipoLogtom)
    xml.newTag('Reg20Item','LogTom',nfs['20'].LogTom)
    xml.newTag('Reg20Item','NumEndTom',nfs['20'].NumEndTom)
    xml.newTag('Reg20Item','ComplEndTom',nfs['20'].ComplEndTom)
    xml.newTag('Reg20Item','BairroTom',nfs['20'].BairroTom)
    xml.newTag('Reg20Item','MunTom',nfs['20'].MunTom)
    xml.newTag('Reg20Item','SiglaUFTom',nfs['20'].SiglaUFTom)
    xml.newTag('Reg20Item','CepTom',nfs['20'].CepTom)
    xml.newTag('Reg20Item','Telefone',nfs['20'].Telefone)
    xml.newTag('Reg20Item','InscricaoMunicipal',nfs['20'].IMTom)
    xml.newTag('Reg20Item','TipoLogLocPre',nfs['20'].TipoLogLocPre)
    xml.newTag('Reg20Item','LogLocPre',nfs['20'].LogLocPre)
    xml.newTag('Reg20Item','NumEndLocPre',nfs['20'].NumEndLocPre)
    xml.newTag('Reg20Item','ComplEndLocPre',nfs['20'].ComplEndLocPre)
    xml.newTag('Reg20Item','BairroLocPre',nfs['20'].BairroLocPre)
    xml.newTag('Reg20Item','MunLocPre',nfs['20'].MunLocPre)
    xml.newTag('Reg20Item','SiglaUFLocpre',nfs['20'].SiglaUFLocpre)
    xml.newTag('Reg20Item','CepLocPre',nfs['20'].CepLocPre)
    xml.newTag('Reg20Item','Email1',nfs['20']['E-mail-1'])
    xml.newTag('Reg20Item','Email2',nfs['20']['E-mail-2'])
    xml.newTag('Reg20Item','Email3',nfs['20']['E-mail-3'])
    xml.newTag('SDTRPS','Reg90')
    xml.newTag('Reg90','QtdRegNormal',nfs['90'].QtdRegNormal)
    xml.newTag('Reg90','ValorNFS',nfs['90'].ValorNFS)
    xml.newTag('Reg90','ValorISS',nfs['90'].ValorISS)
    xml.newTag('Reg90','ValorDed',nfs['90'].ValorDed)
    xml.newTag('Reg90','ValorIssRetTom',nfs['90'].ValorIssRetTom)
    xml.newTag('Reg90','QtdReg30',nfs['90'].QtdReg30)
    xml.newTag('Reg90','ValorTributos',nfs['90'].ValTrib)
//    xml.newTag('Reg90','QtdReg40',nfs['90'].aaa)
//    xml.newTag('Reg90','QtdReg50',nfs['90'].aaa)
*/
    console.log(nfs)

    const xml = document.implementation.createDocument(null, 'Sdt_ProcessarpsIn');
    xml.setAtr('Sdt_ProcessarpsIn','xmlns','NFe')

    console.log(xml)

    xml.newTag('Sdt_ProcessarpsIn','CPFCNPJ',nfs['10'].CpfCnpj)
    xml.newTag('Sdt_ProcessarpsIn','DTIni',nfs['10'].DtIni)
    xml.newTag('Sdt_ProcessarpsIn','DTFin',nfs['10'].DtFin)
    xml.newTag('Sdt_ProcessarpsIn','TipoArq',nfs['10'].TipoArq)
    xml.newTag('Sdt_ProcessarpsIn','Versao',nfs['10'].Versao)
    xml.newTag('Sdt_ProcessarpsIn','Reg20')
    xml.newTag('Reg20','Reg20Item')
    xml.newTag('Reg20Item','TipoNf',nfs['20'].TipoNf)
    xml.newTag('Reg20Item','NumNf',nfs['CONF'].numNFS)
    xml.newTag('Reg20Item','SerNf',nfs['CONF'].SerNf)
    xml.newTag('Reg20Item','DtEmiNf',nfs['20'].DtEmi)
    xml.newTag('Reg20Item','DtHrGerNf',`${nfs['20'].DtEmi} ${(new Date()).getFullTime()}:00`)
    xml.newTag('Reg20Item','CodVernf')
    xml.newTag('Reg20Item','NumRps',nfs['20'].NumRPS)
    xml.newTag('Reg20Item','SerRps',nfs['20'].SerRPS)
    xml.newTag('Reg20Item','DtEmiRps',nfs['10'].DtIni)
    xml.newTag('Reg20Item','TipoCpfCnpjPre',nfs['CONF'].TipoCpfCnpjPre)
    xml.newTag('Reg20Item','CpfCnpjPre',nfs['CONF'].CpfCnpjPre)
    xml.newTag('Reg20Item','RazSocPre',nfs['CONF'].RazSocPre)
    xml.newTag('Reg20Item','LogPre',nfs['CONF'].LogPre)
    xml.newTag('Reg20Item','NumEndPre',nfs['CONF'].NumEndPre)
    xml.newTag('Reg20Item','ComplEndPre',nfs['CONF'].ComplEndPre)
    xml.newTag('Reg20Item','BairroPre',nfs['CONF'].BairroPre)
    xml.newTag('Reg20Item','MunPre',nfs['CONF'].MunPre)
    xml.newTag('Reg20Item','SiglaUFPre',nfs['CONF'].SiglaUFPre)
    xml.newTag('Reg20Item','CepPre',nfs['CONF'].CepPre)
    xml.newTag('Reg20Item','EmailPre',nfs['CONF'].EmailPre)
    xml.newTag('Reg20Item','TipoTribPre',nfs['CONF'].TipoTribPre)
    xml.newTag('Reg20Item','DtAdeSN',nfs['CONF'].DtAdeSN)
    xml.newTag('Reg20Item','AlqIssSN',nfs['CONF'].AlqIssSN)
    xml.newTag('Reg20Item','SitNf',nfs['CONF'].SitNf)
    xml.newTag('Reg20Item','DataCncNf')
    xml.newTag('Reg20Item','MotivoCncNf')
    xml.newTag('Reg20Item','TipoCpfCnpjTom',nfs['CONF'].TipoCpfCnpjTom)

    xml.newTag('Reg20Item','CpfCnpjTom',nfs['20'].CpfCnpjTom)
    xml.newTag('Reg20Item','RazSocTom',nfs['20'].RazSocTom)
    xml.newTag('Reg20Item','LogTom',nfs['20'].LogTom)
    xml.newTag('Reg20Item','NumEndTom',nfs['20'].NumEndTom)
    xml.newTag('Reg20Item','ComplEndTom',nfs['20'].ComplEndTom)
    xml.newTag('Reg20Item','BairroTom',nfs['20'].BairroTom)
    xml.newTag('Reg20Item','MunTom',nfs['20'].MunTom)
    xml.newTag('Reg20Item','SiglaUFTom',nfs['20'].SiglaUFTom)
    xml.newTag('Reg20Item','CepTom',nfs['20'].CepTom)
    xml.newTag('Reg20Item','EMailTom',nfs['20']['E-mail-1'])
    xml.newTag('Reg20Item','LogLocPre',nfs['20'].LogLocPre)
    xml.newTag('Reg20Item','NumEndLocPre',nfs['20'].NumEndLocPre)
    xml.newTag('Reg20Item','ComplEndLocPre',nfs['20'].ComplEndLocPre)
    xml.newTag('Reg20Item','BairroLocPre',nfs['20'].BairroLocPre)
    xml.newTag('Reg20Item','MunLocPre',nfs['20'].MunLocPre)
    xml.newTag('Reg20Item','SiglaUFLocpre',nfs['20'].SiglaUFLocpre)
    xml.newTag('Reg20Item','CepLocPre',nfs['20'].CepLocPre)
    xml.newTag('Reg20Item','CodSrv',nfs['20'].CodSrv)
    xml.newTag('Reg20Item','DiscrSrv',nfs['20'].DiscrSrv)    
    xml.newTag('Reg20Item','VlNFS',nfs['20'].VlNFS)
    xml.newTag('Reg20Item','VlDed',nfs['20'].VlDed)
    xml.newTag('Reg20Item','DiscrDed',nfs['20'].DiscrDed)
    xml.newTag('Reg20Item','VlBasCalc',nfs['20'].VlBasCalc)
    xml.newTag('Reg20Item','AlqIss',nfs['20'].AlqIss)
    xml.newTag('Reg20Item','VlIss',nfs['20'].VlIss)
    xml.newTag('Reg20Item','VlIssRet',nfs['20'].VlIssRet)

    xml.newTag('SDTNotasExport','Reg90')
    xml.newTag('Reg90','QtdRegNormal',nfs['90'].QtdRegNormal)
    xml.newTag('Reg90','ValorNFS',nfs['90'].ValorNFS)
    xml.newTag('Reg90','ValorISS',nfs['90'].ValorISS)
    xml.newTag('Reg90','ValorDed',nfs['90'].ValorDed)
    xml.newTag('Reg90','ValorIssRetTom',nfs['90'].ValorIssRetTom)
    xml.newTag('Reg90','QtdReg30',nfs['90'].QtdReg30)
    xml.newTag('Reg90','ValorTributos',nfs['90'].ValTrib)

    const serializer = new XMLSerializer();
    return serializer.serializeToString(xml)

}

/****** FUNÇÔES *******/

function makeGroup (grupo,rules){

    if(!this.hasOwnProperty(grupo)){
        const out = new Object
        
        for (const campo in rules[grupo]) {
            let value = rules[grupo][campo].def.toString().trim()
            const tipo = rules[grupo][campo].tipo
            const tam = rules[grupo][campo].tam.toString().split('-')
            const min = tam.length == 1 ? '0' : tam[0]
            const max = tam.length == 1 ? tam[0] : tam[1]
            const ocor = rules[grupo][campo].ocor.split('-')
    
            if(tipo=='N'){
                const dec = rules[grupo][campo].dec
                value = (ocor[0] == '1' && value == '') ? '0' : value
                value = (value != '' && ocor[0] == '1') ? value.padStart(min,0) : value
                value = value.substr(0,max)
                value = (value != '' && dec > 0) ? Number(value).toFixed(dec) : value
            }else if(tipo=='D'){
                let dt = new Date()
                dt = `${dt.getFullYear()}-${(dt.getMonth()+1).toString().padStart(2,'0')}-${dt.getDate().toString().padStart(2,'0')}`
                value = (ocor[0] == '1' && value == '') ? dt : value
            }else if(['C','D','H','DH'].includes(tipo)){
                null
            }

            value = value.substr(0,max)    
            if(ocor[0] == '1' && value == ''){
                console.log(`Campo obrigatório vazio: ${grupo}->${campo}`)
            }

            out[campo] = value.toString().trim()
        }
        return out
    }
    return this[grupo]
}

function nfImport(obj,NF){
    for (const grupo in obj) {
        if(NF.hasOwnProperty(grupo)){
            for (const campo in obj[grupo]){
                if(NF.rules[grupo].hasOwnProperty(campo)){
                    switch(NF.rules[grupo][campo].tipo){
                        case 'N':
                            obj[grupo][campo] = onlyNum(obj[grupo][campo])
                        break
                        case 'C':
                            obj[grupo][campo] = onlyAlpha(obj[grupo][campo])
                        break
                        default:
                            obj[grupo][campo] += campo == 'dhEmi' ? 'T07:00:00-03:00' : ''
                            obj[grupo][campo] += campo == 'dhSaiEnt' ? 'T16:00:00-03:00' : ''
                    }
                    NF[grupo][campo] =  obj[grupo][campo].trim()
                }
            }
        }
    }
}

function onlyNum(V){
    let out = ''
    for(let i=0; i< V.length; i++){
        const ascii = V[i].charCodeAt()
        if(ascii>=48 && ascii<=57){
            out+=V[i]
        }
    }
    return out
}

function onlyAlpha(V){    
    return V.normalize("NFD").replace(/[\u0300-\u036f]/g, "")
}

function dateBR(DT){
    return DT.substring(8,10)+'/'+DT.substring(5,7)+'/'+DT.substring(0,4)
}

function IBGE_cMun(C,E){
    C = C.trim().toLowerCase()
    E = E.trim().toUpperCase()
    const cod_UF = {"RO":11,"AC":12,"AM":13,"RR":14,"PA":15,"AP":16,"TO":17,"MA":21,"PI":22,"CE":23,
    "RN":24,"PB":25,"PE":26,"AL":27,"SE":28,"BA":29,"MG":31,"ES":32,"RJ":33,"SP":35,"PR":41,"SC":42,
    "RS":43,"MS":50,"MT":51,"GO":52,"DF":53} 

        if(C != '' && E != ''){

            const Mun_cod = new Promise((resolve,reject) =>{
                fetch(`https://servicodados.ibge.gov.br/api/v1/localidades/estados/${cod_UF[E]}/municipios`)
                .then(function (response){                           
                    if (response.status === 200) { 
                        resolve(response.text());
                    } else { 
                        reject(new Error("Houve algum erro na comunicação com o servidor"));
                    } 
                })                    
            })
            return Mun_cod
    }
}
