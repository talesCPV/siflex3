/*  IMPORTS  */




/*  VARIABLES  */

var doc = new jsPDF({
    orientation: 'p',
    unit: 'mm',
    format: 'a4'
}) 

var txt = new Object
    txt.lineHeigth = 5
    txt.x = 10
    txt.y = 10
    txt.page = 1
    txt.width = doc.internal.pageSize.getWidth() - txt.x
    txt.text
    txt.dim = [90,80] 

var imgData = new Image()
    imgData.src = 'assets/logo.png'

/* FUNCTIONS */

function addPage(Y=46){
    doc.addPage();
    frame()
    header_pdf()    
    txt.y = Y 
}

function getBarcode(N, pos=[txt.dim[0]-41,txt.dim[1]-30, 36, 25] ){
    const bar = newBarcode(N,70)    
    const image = new Image();
    image.src = bar.toDataURL();
    doc.addImage(image, 'png', pos[0],pos[1],pos[2],pos[3]);
}

function clearTxt(y=10,x=10,dim=[90,80]){
    txt = new Object
        txt.lineHeigth = 5
        txt.x = x
        txt.y = y
        txt.page = 1
        txt.width = doc.internal.pageSize.getWidth() - txt.x
        txt.text = ''
        txt.dim = dim 

}

function frame(margin=5){
    doc.rect(margin,margin,txt.dim[0]-margin*2,txt.dim[1]-margin*2)
}

function line(p, direct='h',margin=5, end=margin){

    if(direct == 'h'){
        doc.line(margin,p,txt.dim[0]-end,p)
    }else{
        doc.line(p,margin,p,txt.dim[1]-end)
    }

}

function logo(pos = [14,7,36,25]){
    doc.addImage(imgData, 'png', pos[0], pos[1], pos[2], pos[3]);
}

function addLine(N=1, botton=0, top=46){
    txt.y += txt.lineHeigth * N
    if(txt.y >= doc.internal.pageSize.getHeight() - botton){
        addPage(top)
        return false
    }
    return true
}

function backLine(N=1, botton=0, top=46){
    txt.y -= txt.lineHeigth * N
    return true
}

function box(text,x,y,w,lh=0.8){
    const h = txt.lineHeigth * lh   
    text = text.trim().split('\n')
    for(let i=0; i<text.length; i++){
        const txt = text[i].trim().split(' ')
        let lin = ''
        for(let j=0; j<txt.length; j++){
            if(doc.getTextDimensions(lin+txt[j]+' ').w < w ){
                lin +=  txt[j] + ' '
            }else{
                doc.text(lin.trim(),x,y);
                y += h
                lin =  txt[j] + ' '
                addLine()
            }

        }
        lin.trim() != '' ? doc.text(lin,x,y): '';
        y += h
        addLine()
    }    
}

function center_text(T='',box=[0,doc.internal.pageSize.getWidth()]){
    const text = T==''? txt.text : T
    const w = doc.getTextDimensions(T).w
    const xOffset = (box[1] - box[0] - w) /2;  
    doc.text(T, box[0] + xOffset, txt.y);
    addLine()
}

function right_text(T='',margin=0, pos=doc.internal.pageSize.getWidth()){
    const text = T==''? txt.text : T
    const w = doc.getTextDimensions(T).w
    const xOffset = pos - margin - w 
    doc.text(T, xOffset, txt.y);
}

function block_text(T=''){
    const text = T==''? txt.text.split(' ') : T.split(' ')
    let line = ''

    function print(){

        if(line.length > 0){
            doc.text(line.trim(), txt.x, txt.y);
        }
        addLine()
        line = ''
        if (txt.y >= txt.dim[1]){
            addPage(46)
        }                
    }

    for(let i=0; i< text.length; i++){

        if(text[i].includes('\n')){
            line = line.trim() + ' ' + text[i].trim()
            print()
        }else if(text[i] != ''){
            line = line.trim() + ' ' + text[i].trim()
        }

        length = line.length * (doc.internal.getFontSize() / 4.6)
        if(length > txt.width){
            print()
        }                
    }
    print()
}

function header_pdf(lin_h = 5, font_size = 12){
    ini_y = 13
    logo([14,15,45,10])
    //  CABEÇALHO
    doc.setFontSize(font_size)
    doc.setFont(undefined, 'normal')
    doc.text('Av. Dr. Rosalvo de Almeida Telles, 2070', 97,ini_y);
    doc.text('Nova Cacapava - Cacapava-SP - CEP 12.283-020', 88,ini_y+lin_h);
    doc.text('comercial@flexibus.com.br | (12) 3653-2230', 93,ini_y + (lin_h*2));
    doc.text('CNPJ 00.519.547/0001-06', 111,ini_y+(lin_h*3));    

}

function openPDF(doc,filename){
    const file = doc.output('blob')
    uploadFile(file,`config/user/${localStorage.getItem('id_user')}/temp/`,`${filename}.pdf`).then(()=>{
        window.open(window.location.href+`config/user/${localStorage.getItem('id_user')}/temp/${filename}.pdf`, '_blank').focus();
    })
}