
/*  RELATORIES  */

function print_etq(data){
    
    doc = new jsPDF()  
    const x_ = 60

    clearTxt()
//    frame()

    doc.rect(x_+5,5,txt.dim[0]-5*2,txt.dim[1]-5*2)
    doc.line(x_+5,23,x_+txt.dim[0]-5,23)
    doc.line(x_+5,45,x_+txt.dim[0]-5,45)

    getBarcode(data.cod.padStart(13,'0'),[x_+25,52,40,15])
    logo([x_+30,10,30,10])

    doc.setFontSize(8)
    doc.setFont(undefined, 'bold')
    doc.text(data.descricao, x_+6,30);
    doc.text('Forn.:', x_+6,35);
    doc.text('Cod.:', x_+6,40);
    doc.text('Cod. Orig:', x_+40,40);

    doc.setFont(undefined,'normal')
    doc.text(data.nome.toUpperCase(), x_+15,35);
    doc.text(data.cod.padStart(13,'0') , x_+15,40);
    doc.text(data.cod_cli.padStart(13,'0') , x_+55,40);

//    doc.save('etiqueta.pdf')
    openPDF(doc,'etiqueta.pdf')
}

function print_pcp(tbl){

    doc = new jsPDF({
        orientation: 'landscape',
        format: 'a4'
    })  

    clearTxt(10,10,[297,210])
    header_pdf(4,10)
   
    doc.setFontSize(45)
    doc.text('PCP', 200,23);
    doc.setFontSize(12)
    doc.text(`de ${tbl[1].data.day.getFormatBR()} a ${tbl[7].data.day.getFormatBR()}`, 186,28);
  
    txt.y = 30

    const head = []
    const body = []

    for(let y=0; y<tbl.length; y++){
        const row =[]
        for(let x=0; x<tbl[y].cells.length; x++){           
            row.push(tbl[y].cells[x].innerHTML)
        }

        y==0 ? head.push(row) : body.push(row)
    }

    doc.autoTable({
        head: head,
        body: body,

        columnStyles: {
            0: {cellWidth: 3,
                fontSize: 10}
        },
        
        styles :{fontSize: 10},
        startY: txt.y,
        theme: 'grid',
        headStyles: {
            fillColor: [46, 128, 186],
            minCellHeight:5,
            halign: 'center'
        },
        bodyStyles: {
            fontSize: 8,
            minCellHeight: 22,
            halign: 'center',
            valign: 'center'
        }        
    });

//    doc.save('pcp.pdf')
    openPDF(doc,'pcp.pdf')
}

function carrosRelat(tbl, dt){
    let color = [0,0,0]
    let fontSize = 11
    let desc = 0
    const dt_ini = dataBR(dt.data_ini)
    const dt_fin = dataBR(dt.data_fin)
    
    function postCli(data){      
        doc.setFontSize(11)
        doc.setFont(undefined, 'bold')
        doc.text('Cliente: ' + data.empresa.trim().toUpperCase() ,15,txt.y)
        doc.setFont(undefined, 'normal')
        doc.setFontSize(10)
        data.cnpj.trim() != '' ? doc.text('CNPJ: ' + getCNPJ(data.cnpj) ,140,txt.y) :0
        addLine()
        data.endereco.trim() != '' ? doc.text('End. '+ data.endereco.trim().toUpperCase()+','+data.num.trim(),15,txt.y) :0
        data.cidade.trim()!= '' ? doc.text(data.cidade.trim().toUpperCase()+'-'+data.estado,140,txt.y) :0    
        addLine()
        doc.text(dt.org+' de '+ dt_ini+' até '+dt_fin,15,txt.y)
        color = dt.cor
        desc = dt.desc
        doc.setTextColor(color); 
        addLine()
        //  TEXTO DE OBS
        if(document.querySelector('#edtObs').value.trim() != ''){
            addLine()
            doc.setFontSize(8)
            box(document.querySelector('#edtObs').value.trim(),15,txt.y,170,1,false)
        }
        doc.setTextColor(0,0,0); 
    }

    function postTable(){
        function pushTot(title,value){
            tbl_body.push([{
                content: title,
                colSpan: colspan,
                styles: { halign: 'left', fillColor: [37, 68, 65], textColor:[255]},
              },
              {
                content: value, 
                styles: { halign: 'right', fillColor: [37, 68, 65], textColor:[255] },         
              }])
        }

        let head
        let colspan
        let celWidth
        let obj = ''
        if(dt.org == 'Análise'){
            if(dt.relatorio){
                head =  [[dt.objeto,dt.org, "Exec.",'Valor']]
                celWidth = 20
            }else{
                head =  [[dt.objeto,"Local","Feito", "Serviços Previstos"]]
                celWidth = 100
            }
            colspan = 3
        }else{
            if(dt.relatorio){
                head =  [['Data',dt.objeto,"Pedido", "NF.",'Valor']]
                colspan = 4
                celWidth = 20
            }else{
                head =  [['Data',dt.objeto,"Serviço Executado"]]
                colspan = 2
                celWidth = 10
            }
        }
        fontSize = dt.fontsize
        obj = dt.objeto

        pushTot(qtd+' '+obj+'(s)','Total '+viewMoneyBR(subTot.toFixed(2)))
        qtd = 0

        doc.autoTable({
            head: head,
            body: tbl_body,

            columnStyles: {
                0: {cellWidth: 25},
                1: {cellWidth: 25}
            },
            
            styles :{fontSize: fontSize},
            startY: txt.y
        });

        txt.y = doc.previousAutoTable.finalY
        tbl_body = []
        total += subTot
        subTot=0  

        addLine()
        line(txt.y)
        addLine()
    }

    jsPDF.autoTableSetDefaults({
        headStyles: { fillColor: [37, 68, 65] },
    })

    doc = new jsPDF()  

    clearTxt(37,10,[210,297])
//    frame()
    header_pdf()

    line(txt.y)
    addLine(2)

    doc.setFontSize(15)
    doc.setFont(undefined, 'bold')
    center_text(dt.titulo)
    doc.setFont(undefined, 'normal')
    doc.setFontSize(12)
    addLine()

    let lastEmp
    let tbl_body = []
    let subTot = 0
    let total = 0 
    let qtd = 0   
    for(let i=1; i< tbl.rows.length;i++){
        const data = tbl.rows[i].data
        if(data.id_emp != lastEmp){
            lastEmp = data.id_emp
            if(i!= 1){
                postTable()                
            }         
            postCli(data)
        }

        if(dt.org == 'Análise'){
            if(dt.relatorio){
                tbl_body.push([data.num_carro,dataBR(data.data_analise),data.exec=='1'?'SIM':'NÃO',viewMoneyBR(parseFloat(data.valor).toFixed(2))]) 
            }else{
                tbl_body.push([data.num_carro,data.local,data.exec=='1'?'SIM':'NÃO',data.obs])
                tbl_body.push(['','','','Valor: '+viewMoneyBR(parseFloat(data.valor).toFixed(2))])
                tbl_body.push(['','','',''])
                }
        }else{
            if(dt.relatorio){
                tbl_body.push([dataBR(data.data_exec),data.num_carro,data.pedido,data.nf,viewMoneyBR(parseFloat(data.valor).toFixed(2))]) 
            }else{
                tbl_body.push([dataBR(data.data_exec),data.num_carro,data.obs])
                tbl_body.push(['','','Valor: '+viewMoneyBR(parseFloat(data.valor).toFixed(2))])
            }
        }
        qtd++
        subTot += parseFloat(data.valor)
    }

    postTable()
    addLine()
    doc.setFont(undefined, 'bold')
    if(desc > 0){
        doc.setFontSize(11)
        right_text('Desconto: '+ viewMoneyBR(desc.toFixed(2)),17)
        addLine(0.4)
        line(txt.y,'h',150,15)
        addLine()            
        right_text('Total '+ viewMoneyBR((total-desc).toFixed(2)),17)
        addLine(2) 
    } 
/*
    if(['AnaFrotaOrc'].includes(dt.org)){
        doc.setTextColor(color); 
        addLine()
        doc.setFontSize(8)       
        center_text('Lembrando que até a data da execução poderá haver acrécimos de serviço')
        addLine(0.3)
        center_text('Recomenda-se corrigir os problemas o mais rápido possível')
        doc.setFont(undefined, 'normal')
        doc.setFontSize(10)
        doc.setTextColor(0,0,0); 
        addLine()
    }

    if(['AnaFrota','AnaFrotaOrc'].includes(dt.org)){
        if(dt.rodape.trim().length > 0){
            doc.setTextColor(dt.cor);
            box(dt.rodape,15,txt.y,170,0.7)
        }
    }else{
        if(dt.rodape.trim().length > 0){
            doc.setTextColor(dt.cor);
            box(dt.rodape,15,txt.y,170,0.7)
        }
    }
*/


//    doc.save('RelAnaFrot.pdf')
    openPDF(doc,'RelAnaFrot.pdf')

}

function print_finan(obj){
  
    jsPDF.autoTableSetDefaults({
        headStyles: { fillColor: [37, 68, 65] },
    })

    let tbl_body = []
    let total = 0
    for(let i=1; i< obj.rows.length;i++){
        const data = obj.rows[i].data
        tbl_body.push([data.id,data.tipo,data.origem,data.ref.substr(0,15).toUpperCase(),data.emp.substr(0,15).toUpperCase(),dataBR(data.data_pg),data.pgto,viewMoneyBR(parseFloat(data.preco).toFixed(2))])
        total += data.tipo =='ENTRADA' ? parseFloat(data.preco) : -parseFloat(data.preco) 

    }

    doc = new jsPDF();
    
    clearTxt(37,10,[210,297])
    frame()
    header_pdf()
    line(txt.y)
    addLine(2)
    doc.setFontSize(23)
    doc.text('Relatório Financeiro', 70,txt.y);
    addLine()
    if(document.querySelector('#ckbData').checked){
        const gap = 'de '+dataBR(document.querySelector('#edtIni').value)+' até '+dataBR(document.querySelector('#edtFin').value)
        doc.setFontSize(12)
        doc.text(gap, 80,txt.y);
        addLine()
    }
    
    doc.setFontSize(12)

    doc.autoTable({
        head: [["Cod", "Tipo", "Orig.",'Referência','Sacado','Venc.','Pgto','Valor']],
        body: tbl_body,
        startY: txt.y      
    });

    txt.y = doc.previousAutoTable.finalY

    addLine()

    doc.text('Total    '+viewMoneyBR(total.toFixed(2)), 155,txt.y);

//    doc.save('RelFinan.pdf')
    openPDF(doc,'RelFinan.pdf')

}

function print_prod(obj){
   
    jsPDF.autoTableSetDefaults({
        headStyles: { fillColor: [37, 68, 65] },
    })


    let tbl_body = []
    let total = 0
    for(let i=1; i< obj.rows.length;i++){
        const data = obj.rows[i].data                
        tbl_body.push([data.cod,data.descricao.substr(0,25).toUpperCase(),data.tipo,data.nome.substr(0,15).toUpperCase(),data.cod_bar,data.estoque,data.unidade])
    }

    doc = new jsPDF();
    
    clearTxt(37,10,[210,297])
    frame()
    header_pdf()
    line(txt.y)
    addLine(2)
    doc.setFontSize(23)
    doc.text('Lista de Produtos', 70,txt.y);
    addLine()
    doc.setFontSize(12)

    doc.autoTable({
        head: [["Cod","Descrição",'Tipo.','Fornecedor',"Cod. Forn.",'Estq.', "Und."]],
        body: tbl_body,
        startY: txt.y      
    });

    txt.y = doc.previousAutoTable.finalY

//    doc.save('relatProd.pdf')
    openPDF(doc,'relatProd.pdf')

}

function print_cotacao(ped,tipo='cot'){
 
    const show_val = document.querySelector('#ckbValor').checked

    jsPDF.autoTableSetDefaults({
        headStyles: { fillColor: [67,180,126] },
    })

    doc = new jsPDF();
    
    clearTxt(37,10,[210,297])
    frame()
    header_pdf()
    line(txt.y)
    addLine()

//  CABEÇALHO    
    doc.setFontSize(10)
    doc.text(ped.id +' - '+ (ped.status=='ABERTO' ? 'COTAÇÃO: ' : 'PEDIDO: ') + ped.num_ped.trim().toUpperCase()  ,10,txt.y)
    doc.text('Data:' + dataBR(ped.data_ped) ,172,txt.y)
    addLine()
    doc.setFontSize(11)
    doc.setFont(undefined, 'bold')
    doc.text('Cliente:' + ped.EMPRESA.trim().toUpperCase() ,10,txt.y)
    doc.setFont(undefined, 'normal')
    doc.setFontSize(10)
    addLine()
    ped.END.trim() != '' ? doc.text('End. '+ ped.END.trim().toUpperCase()+','+ped.NUM.trim(),10,txt.y) :0 
    ped.CIDADE.trim()!= '' ? doc.text(ped.CIDADE.trim().toUpperCase()+'-'+ped.UF,120,txt.y) :0 
    ped.END.trim() == '' && ped.CIDADE.trim() == '' ? 0 : addLine()
    ped.CEP == null || ped.CEP.trim() == '' ? 0 : doc.text('CEP:'+ getCEP(ped.CEP),10,txt.y)
    ped.TEL == null || ped.TEL.trim() == '' ? 0 : doc.text('Tel:'+ getFone(ped.TEL),80,txt.y)
    ped.CNPJ== null || ped.CNPJ.trim()== '' ? 0 : doc.text('CNPJ:'+ getCNPJ(ped.CNPJ),120,txt.y)
    ped.IE  == null || ped.IE.trim()  == '' ? 0 : doc.text('IE:'+ getIE(ped.IE),172,txt.y)
    addLine()
    ped.comp != null ? doc.text('Comprador:'+ped.comp.trim().toUpperCase(),10,txt.y) :0    
    ped.resp != null ? doc.text('Vendedor:'+ ped.resp.trim().toUpperCase(),80,txt.y) :0
    doc.text('Prev. Entrega:'+ dataBR(ped.data_ent),157,txt.y)
    addLine(0.7)
    if(ped.obs != null && ped.obs.trim() != ''){
        addLine()
        doc.text('Obs:',10,txt.y)
        addLine()
        doc.setFont(undefined, 'bold')
        box(ped.obs,10,txt.y,170,1,false)
        doc.setFont(undefined, 'normal')
    }
    line(txt.y)
    addLine(2)

    doc.setFontSize(15)
    doc.setFont(undefined, 'bold')
    if(tipo == 'cot'){
        if(show_val){
            center_text((ped.status=='ABERTO' ? 'COTAÇÃO - ' : 'PEDIDO - ')+ ped.num_ped.trim().toUpperCase())   
        }else{
            center_text('Preparação de Material')
        }
    }else{
        center_text('Recibo de Material')
    }
    

//    TABELA
    let tbl_body = []
    let head
    for(let i=0; i< ped.itens.length; i++){
        if(show_val){
            tbl_body.push([ped.itens[i].cod_prod,ped.itens[i].descricao.substr(0,40).toUpperCase(),ped.itens[i].und,ped.itens[i].qtd,viewMoneyBR(parseFloat(ped.itens[i].preco).toFixed(2)),viewMoneyBR(ped.itens[i].TOTAL)])
            head= [["Cod","Descrição",'Und.','Qtd.',"Preço Unit.",'Sub Total.']]
        }else{
            tbl_body.push([ped.itens[i].cod_prod,ped.itens[i].descricao.substr(0,50).toUpperCase(),ped.itens[i].und,ped.itens[i].qtd])
            head= [["Cod","Descrição",'Und.','Qtd.']]
        }
    }

    doc.autoTable({
        head: head,
        body: tbl_body,
        startY: txt.y      
    });

    txt.y = doc.previousAutoTable.finalY
    addLine()


//  TOTAL  
    doc.setFontSize(12)
    if(show_val){  
        if(ped.desconto != '0') {
            addLine(0.5)
            right_text('Subtotal '+ viewMoneyBR(parseFloat(ped.VALOR).toFixed(2)),17)
            addLine()
            right_text('Desconto '+ viewMoneyBR(parseFloat(ped.desconto).toFixed(2)),17)
            addLine(0.4)
            line(txt.y,'h',150,15)
            addLine()
        }        
        right_text('Total '+ viewMoneyBR((ped.total - parseFloat(ped.desconto)).toFixed(2)),17)
    }

//  ASS. RECIBO DE MATERIAL

    if(tipo == 'rec'){
        addLine(5)
        doc.setFontSize(9)
        doc.setFont(undefined, 'normal')
        center_text('______________________________________________________')
        center_text('Fico ciente da cobranca que sera feita posteriormente')
    }
    
//  CONDIÇÂO DE PGTO  
    if(show_val && ped.cond_pgto.trim() != ''){
        if(txt.y < 250){
            txt.y = 250
        }
        doc.setFontSize(8)
        line(txt.y)
        addLine(0.7)
        doc.text('Condição de Pagamento:',10,txt.y)
        addLine(0.7)
        box(ped.cond_pgto.trim(),10,txt.y,170,0.7)    
    }

//    doc.save('cotacao.pdf')
    openPDF(doc,'cotacao.pdf')

}

function print_pedcomp(){
   
    const show_val = document.querySelector('#ckbValor').checked
    const data = main_data.com_view_comp.data


    jsPDF.autoTableSetDefaults({
        headStyles: { fillColor: [37, 68, 65] },
    })

    doc = new jsPDF();
    
    clearTxt(37,10,[210,297])
    frame()
    header_pdf()
    line(txt.y)
    addLine()

//  CABEÇALHO    
    doc.setFontSize(10)
    doc.text(data.label,10,txt.y)
    doc.text('Data:' + dataBR(data.data_ent) ,172,txt.y)
    addLine()
    doc.setFontSize(11)
    doc.setFont(undefined, 'bold')
    doc.text('Solicitante: Flexibus Sanfonados LTDA',10,txt.y)
    doc.setFont(undefined, 'normal')
    doc.setFontSize(10)
    addLine()
    doc.text('Comprador:'+data.resp.trim().toUpperCase(),10,txt.y)
    addLine()
    doc.text('End. Av. Dr. Rosalvo de Almeida Telles, 2070',10,txt.y)
    doc.text('Caçapava-SP',120,txt.y)
    addLine()
    doc.text('CEP: 12.283-020',10,txt.y)
    doc.text('Tel: (12)3653-2230',80,txt.y)
    doc.text('CNPJ: 00.519.547/0001-06',120,txt.y)
    doc.text('IE: 234.033.845.113',170,txt.y)
    addLine()
    doc.setFontSize(11)
    doc.setFont(undefined, 'bold')
    doc.text('Fornecedor:' + data.fantasia.trim().toUpperCase() ,10,txt.y)
    doc.setFont(undefined, 'normal')
    doc.setFontSize(10)
    addLine()
    doc.text('End. '+data.endereco+','+data.num,10,txt.y)
    doc.text(data.cidade+'-'+data.estado,120,txt.y)
    addLine()
    doc.text('Bairro:'+data.bairro,10,txt.y)
    addLine()
    doc.text('Obs:',10,txt.y)
    addLine()
    doc.setFont(undefined, 'bold')
    box(data.OBS,10,txt.y,170)
    doc.setFont(undefined, 'normal')
    line(txt.y)
    addLine(2)
    doc.setFontSize(15)
    doc.setFont(undefined, 'bold')
    center_text(data.label)
    
//    TABELA

    let tbl_body = []
    let total = 0
    let head
    for(let i=0; i< data.itens.length;i++){
        if(show_val){
            tbl_body.push([data.itens[i].cod_cli,data.itens[i].descricao.substr(0,40).toUpperCase(),data.itens[i].unidade,data.itens[i].qtd,viewMoneyBR(parseFloat(data.itens[i].preco).toFixed(2)),viewMoneyBR(data.itens[i].total)])
            head= [["Cod","Descrição",'Und.','Qtd.',"Preço Unit.",'Sub Total.']]
        }else{
            tbl_body.push([data.itens[i].cod_cli,data.itens[i].descricao.substr(0,40).toUpperCase(),data.itens[i].unidade,data.itens[i].qtd])
            head= [["Cod","Descrição",'Und.','Qtd.']]
        }
        total += parseFloat(data.itens[i].total)
    }

    doc.autoTable({
        head: head,
        body: tbl_body,
        startY: txt.y      
    });

    txt.y = doc.previousAutoTable.finalY
    addLine()


//  TOTAL  
    doc.setFontSize(12)
    if(show_val){  
        right_text('Total '+ viewMoneyBR((total).toFixed(2)),17)
    }

//    doc.save('pedcompra.pdf')
    openPDF(doc,'pedcompra.pdf')
}

function timbrado(titulo,texto){

    jsPDF.autoTableSetDefaults({
        headStyles: { fillColor: [37, 68, 65] },
    })

    doc = new jsPDF();
    
    clearTxt(37,10,[210,297])
    frame()
    logo([14,15,45,10])

//    line(txt.y)


    txt.y = 280

    doc.setFontSize(8)
    doc.setFont(undefined, 'normal')
    center_text('Av. Dr. Rosalvo de Almeida Telles, 2070  Cacapava-SP - CEP 12.283-020 - CNPJ 00.519.547/0001-06')
    center_text('www.flexibus.com.br | comercial@flexibus.com.br | (12) 3653-2230')

    txt.y = 50
    doc.setFontSize(titulo.font)
    doc.setTextColor(titulo.color);
    doc.setFont(undefined, 'bold')
    if(titulo.align == '1'){
        doc.text(titulo.text,10,txt.y)
    }else if(titulo.align == '2'){
        center_text(titulo.text)
    }else if(titulo.align == '3'){
        right_text(titulo.text,10)
    }

    txt.y = 50 + parseInt(titulo.font)
    doc.setFontSize(texto.font)
    doc.setTextColor(texto.color);
    doc.setFont(undefined, 'normal')
    box(texto.text,10,txt.y, doc.internal.pageSize.getWidth()-20)

    if(texto.ass != ''){
        const w = doc.getTextDimensions(texto.ass).w +4
        addLine()
        txt.x = texto.align == '1' ? 20 : texto.align=='2' ? doc.internal.pageSize.getWidth()/2 - w/2 : doc.internal.pageSize.getWidth() - w - 10
        doc.line(txt.x - 3,txt.y-txt.lineHeigth,txt.x+w,txt.y-txt.lineHeigth)
        addLine
        doc.text(texto.ass,txt.x,txt.y)
    }

//    doc.save('timbrado.pdf')
    openPDF(doc,'timbrado.pdf')

}

function holerite(func,tipo='holerite'){

    function drawFrame(Y=5,mode='ADTO'){
        const date =  meses[func.data.getMonth()] +'/'+ func.data.getFullYear()
        const pageWidth = doc.internal.pageSize.getWidth()
        txt.y = Y+5
//        doc.rect(Y,5,doc.internal.pageSize.getWidth()-10,Y+100)        
        logo([10,Y+5,20,5])
        doc.setFontSize(8)
        doc.setFont(undefined, 'bold')    
        doc.text('Flexibus Sanfonados LTDA.',35,txt.y)
        center_text('RECIDO DE PAGAMENTO',[165,pageWidth-5])
        backLine()
        addLine(0.7)
        doc.text('Rua Dr. Rosalvo de Almeida Telles, 2070',35,txt.y)
        doc.text('Caçapava-SP',105,txt.y)
        
        center_text(mode,[165,pageWidth-5])
        backLine()
        addLine(0.7)
        doc.text('00.519.547/0001-06',35,txt.y)
        center_text(date,[165,pageWidth-5])
       
        backLine(0.5)
        line(txt.y)
        
        addLine()
        doc.text(func.nome,10,txt.y)
        doc.text(func.cbo,105,txt.y)
        addLine(0.7)
        doc.text(func.cargo,10,txt.y)
        doc.text('ADMISSÂO '+dataBR(func.data_adm),105,txt.y)
        addLine(0.7)
        line(txt.y)
        addLine(0.7)
        doc.text('Descrição',10,txt.y)
        doc.text('Referência',90,txt.y)
        doc.text('Vencimentos',135,txt.y)
        doc.text('Descontos',180,txt.y)
        addLine()

        const salario = new Object
            salario.tipo = func.tipo
            salario.valor = parseFloat(func.salario)
            salario.impostos = new Object
            if(salario.tipo == 'HORA'){
                salario.adto = (salario.valor * 88).toFixed(2)
                salario.bruto = salario.valor * (func.horas.hr + (func.horas.adn * 1.5) + (func.horas.he * 2) + (func.horas.he_adn * 2.5) )
                salario.descontos = salario.valor * 88
                salario.h_trab = func.horas.hr + func.horas.adn    
            }else{
                salario.adto = (salario.valor * 0.4).toFixed(2)
                salario.bruto = salario.valor
                salario.descontos = salario.valor * 0.4
                salario.h_trab = 220
            }

        for(let i=0; i<imp.length; i++){
            if(salario.bruto >= parseFloat(imp[i].ini_range) && salario.bruto <= parseFloat(imp[i].fin_range)){
                salario.impostos[imp[i].nome] = imp[i]
            }
        }

        if(mode=='ADTO'){

            doc.setFont(undefined, 'normal')

            doc.text('ADIANTAMENTO SALARIAL',10,txt.y)
            doc.text(salario.h_trab.toFixed(2),90,txt.y)
            doc.text(salario.adto,135,txt.y)

            doc.setFont(undefined, 'bold')    

            txt.y = Y+80
            line(txt.y)
            addLine(0.7)
            doc.text('Total Venc.',135,txt.y)
            doc.text('Total Desc.',180,txt.y)
            addLine(0.7)
            doc.text(salario.adto,135,txt.y)
            doc.text('0',180,txt.y)
            addLine(0.7)
            doc.text('Total Liq. ->',135,txt.y)
            doc.text(viewMoneyBR(salario.adto),180,txt.y)
            addLine(0.7)
            line(txt.y)
            addLine(0.7)
            doc.text('Salario Base',10,txt.y)
            doc.text('SalContr.INSS',60,txt.y)
            doc.text('Base Calc. FGTS',90,txt.y)
            doc.text('FGTS do MES',120,txt.y)
            doc.text('Base Calc. IRRF',150,txt.y)
            doc.text('Faixa IRRF',180,txt.y)
            addLine(0.7)
            doc.text(viewMoneyBR(salario.valor.toFixed(2)),10,txt.y)
            doc.text('*****',65,txt.y)
            doc.text('*****',95,txt.y)
            doc.text('*****',125,txt.y)
            doc.text('*****',155,txt.y)
            doc.text('*****',185,txt.y)

            addLine(0.7)
            line(txt.y)
            addLine(0.7)

        }else if(mode=='PGTO'){
//            salario.descontos = parseFloat(salario.adto)
            doc.setFont(undefined, 'normal')

            if(salario.tipo == 'HORA'){
                doc.text('SALARIO',10,txt.y)
                doc.text(salario.h_trab.toFixed(2),90,txt.y)
                doc.text((salario.h_trab * salario.valor).toFixed(2),135,txt.y)
                addLine(0.7)
                doc.text('REPOUSO SEMANAL REMUNERADO',10,txt.y)
                doc.text((salario.h_trab / func.horas.dsr).toFixed(2),90,txt.y)
                doc.text((salario.h_trab * salario.valor / func.horas.dsr).toFixed(2),135,txt.y)
                addLine(0.7)
                salario.bruto += salario.h_trab * salario.valor / func.horas.dsr

//                salario.bruto = salario.valor * (func.horas.hr + (func.horas.adn * 1.2) + (func.horas.he * 2) + (func.horas.he_adn * 2.2) )
                if(func.horas.he > 0){
                    doc.text('HORA EXTRA 100%',10,txt.y)
                    doc.text(func.horas.he.toFixed(2),90,txt.y)
                    doc.text((func.horas.he * 2 * salario.valor).toFixed(2),135,txt.y)
                    addLine(0.7)    
                    doc.text('D.S.R. SOBRE HORAS EXTRAS',10,txt.y)
//                    doc.text(func.horas.he.toFixed(2),90,txt.y)
                    doc.text((func.horas.he * 2 * salario.valor / func.horas.dsr).toFixed(2),135,txt.y)
                    addLine(0.7)    
                    salario.bruto += func.horas.he * 2 * salario.valor / func.horas.dsr

                }
                if(func.horas.adn > 0){
                    doc.text('ADICIONAL NOTURNO 50%',10,txt.y)
                    doc.text(func.horas.adn.toFixed(2),90,txt.y)
                    doc.text((func.horas.adn * 0.5 * salario.valor).toFixed(2),135,txt.y)
                    addLine(0.7)    
                }
                if(func.horas.he_adn > 0){
                    doc.text('H. EXTRA 100% AD. NOTURNO 50%',10,txt.y)
                    doc.text(func.horas.he_adn.toFixed(2),90,txt.y)
                    doc.text((func.horas.he_adn * 2.5 * salario.valor).toFixed(2),135,txt.y)
                    addLine(0.7)    
                }

            }else{
                doc.text('SALARIO',10,txt.y)
                doc.text(salario.h_trab.toFixed(2),90,txt.y)
                doc.text(salario.bruto.toFixed(2),135,txt.y)
                addLine(0.7)    
                doc.text('REPOUSO SEMANAL REMUNERADO',10,txt.y)
                doc.text((salario.h_trab/5).toFixed(2),90,txt.y)
                doc.text((salario.bruto/5).toFixed(2),135,txt.y)
                addLine(0.7)    
            }

            doc.text('ADIANTAMENTO',10,txt.y)
            doc.text(salario.adto,180,txt.y)
            addLine(0.7)
            if(salario.impostos.FGTS != undefined){
                salario.impostos.FGTS.base = viewMoneyBR(salario.valor.toFixed(2))
                salario.impostos.FGTS.val = salario.impostos.FGTS.tipo == 'PERC' ? (salario.bruto - parseFloat(salario.impostos.FGTS.ini_range)) * (parseFloat(salario.impostos.FGTS.valor) / 100) + parseFloat(salario.impostos.FGTS.acumulado) : parseFloat(salario.impostos.FGTS.valor)
            }

            if(salario.impostos.INSS != undefined){
                salario.impostos.INSS.base = salario.impostos.INSS.tipo == 'PERC' ? parseFloat(salario.bruto) : parseFloat(salario.impostos.INSS.ini_range)
                salario.impostos.INSS.val = salario.impostos.INSS.tipo == 'PERC' ? (salario.bruto - parseFloat(salario.impostos.INSS.ini_range)) * (parseFloat(salario.impostos.INSS.valor) / 100) + parseFloat(salario.impostos.INSS.acumulado) : parseFloat(salario.impostos.INSS.valor)
                salario.descontos += salario.impostos.INSS.val
                doc.text('INSS SOBRE SALÁRIO',10,txt.y)
                doc.text(salario.impostos.INSS.base.toFixed(2),90,txt.y)
                doc.text(salario.impostos.INSS.val.toFixed(2),180,txt.y)
                addLine(0.7)
            }
            if(salario.impostos.IRRF != undefined){
                salario.impostos.IRRF.base = salario.impostos.IRRF.tipo == 'PERC' ? parseFloat(salario.impostos.IRRF.valor) : parseFloat(salario.impostos.IRRF.ini_range)
                salario.impostos.IRRF.val = salario.impostos.IRRF.tipo == 'PERC' ? (salario.bruto - salario.impostos.INSS.val - parseFloat(salario.impostos.IRRF.ini_range)) * (parseFloat(salario.impostos.IRRF.valor) / 100) + parseFloat(salario.impostos.IRRF.acumulado) : parseFloat(salario.impostos.IRRF.valor)
                salario.descontos += salario.impostos.IRRF.val
                doc.text('IRRF SOBRE SALÁRIO',10,txt.y)
                doc.text(salario.impostos.IRRF.base.toFixed(2),90,txt.y)
                doc.text(salario.impostos.IRRF.val.toFixed(2),180,txt.y)
                addLine(0.7)
            }
            if(salario.impostos.VALE_TRANSP != undefined){
                salario.impostos.VALE_TRANSP.base = salario.impostos.VALE_TRANSP.tipo == 'PERC' ? parseFloat(salario.impostos.VALE_TRANSP.valor) : parseFloat(salario.impostos.VALE_TRANSP.ini_range)
                salario.impostos.VALE_TRANSP.val = salario.impostos.VALE_TRANSP.tipo == 'PERC' ? (salario.bruto - parseFloat(salario.impostos.VALE_TRANSP.ini_range)) * (parseFloat(salario.impostos.VALE_TRANSP.valor) / 100) + parseFloat(salario.impostos.VALE_TRANSP.acumulado) : parseFloat(salario.impostos.VALE_TRANSP.valor)
                salario.descontos += salario.impostos.VALE_TRANSP.val
                doc.text('VALE TRANSPOSTE',10,txt.y)
                doc.text(salario.impostos.VALE_TRANSP.base.toFixed(2),90,txt.y)
                doc.text(salario.impostos.VALE_TRANSP.val.toFixed(2),180,txt.y)
                addLine(0.7)
            }

            doc.setFont(undefined, 'bold')   

            txt.y = Y+80
            line(txt.y)
            addLine(0.7)
            doc.text('Total Venc.',135,txt.y)
            doc.text('Total Desc.',180,txt.y)
            addLine(0.7)
            doc.text(salario.bruto.toFixed(2),135,txt.y)
            doc.text(salario.descontos.toFixed(2),180,txt.y)
            addLine(0.7)
            doc.text('Total Liq. ->',135,txt.y)
            doc.text(viewMoneyBR((salario.bruto-salario.descontos).toFixed(2)),180,txt.y)
            addLine(0.7)
            line(txt.y)
            addLine(0.7)
            doc.text('Salario Base',10,txt.y)
            doc.text('SalContr.INSS',60,txt.y)
            doc.text('Base Calc. FGTS',90,txt.y)
            doc.text('FGTS do MES',120,txt.y)
            doc.text('Base Calc. IRRF',150,txt.y)
            doc.text('Faixa IRRF',180,txt.y)
            addLine(0.7)
            doc.text(viewMoneyBR(salario.valor.toFixed(2)),10,txt.y)
            doc.text(salario.impostos.INSS != undefined ? salario.impostos.INSS.base.toFixed(2) : '*****',65,txt.y)
            doc.text(salario.impostos.FGTS != undefined ? salario.bruto.toFixed(2) : '*****',95,txt.y)     
            doc.text(salario.impostos.FGTS != undefined ? salario.impostos.FGTS.val.toFixed(2) : '*****',125,txt.y)
            doc.text(salario.impostos.IRRF != undefined ? salario.bruto.toFixed(2) : '*****',155,txt.y)
            doc.text(salario.impostos.IRRF != undefined ? salario.impostos.IRRF.base.toFixed(2) : '*****',185,txt.y)

            addLine(0.7)
            line(txt.y)
            addLine(0.7)

        }else if(mode=='EMPRESTIMO'){

            const pgto = func.pgto
            doc.setFont(undefined, 'normal')

            let emp =  parseFloat(pgto[0].valor)
            let tot = 0
            for(let i=0; i<pgto.length; i++){

                const dt = typeof pgto[i].data=='object' ? pgto[i].data.getFullDateTime().date() : pgto[i].data.date()
                const parcela = i.toString().padStart(2,0)


                tot += i>0? parseFloat(pgto[i].valor) : 0
                doc.text( `${dt}  ${pgto[i].obs.toUpperCase()}` ,10,txt.y)
                //            doc.text(parseFloat(func.horas.vale).toFixed(2),90,txt.y)
                const valor = parseFloat( pgto[i].valor).toFixed(2)
                doc.text(valor , i==0? 135 : 180,txt.y)
    
                addLine(0.7)
                    
            }
            doc.setFont(undefined, 'bold')    
            txt.y = Y+80
            line(txt.y)
            addLine(0.7)
            doc.text('Total Empréstimo ->',135,txt.y)
            doc.text(viewMoneyBR(emp.toFixed(2)),180,txt.y)
            addLine(0.7)
            doc.text('Total Desconto     ->',135,txt.y)
            doc.text('('+viewMoneyBR(tot.toFixed(2))+')',180,txt.y)
            addLine(0.7)
            doc.text('Saldo Devedor      ->',135,txt.y)
            doc.text('('+viewMoneyBR((emp-tot).toFixed(2))+')',180,txt.y)
            addLine(0.7)
            line(txt.y)
            addLine(0.7)
            doc.text('Salario Base',10,txt.y)
            doc.text('SalContr.INSS',60,txt.y)
            doc.text('Base Calc. FGTS',90,txt.y)
            doc.text('FGTS do MES',120,txt.y)
            doc.text('Base Calc. IRRF',150,txt.y)
            doc.text('Faixa IRRF',180,txt.y)
            addLine(0.7)
            doc.text(viewMoneyBR(salario.valor.toFixed(2)),10,txt.y)
            doc.text('*****',65,txt.y)
            doc.text('*****',95,txt.y)
            doc.text('*****',125,txt.y)
            doc.text('*****',155,txt.y)
            doc.text('*****',185,txt.y)

            addLine(0.7)
            line(txt.y)
            addLine(0.7)

        }else{
            doc.setFont(undefined, 'normal')

            doc.text(today.getFormatBR()+' - VALE',10,txt.y)
            doc.text(parseFloat(func.horas.vale).toFixed(2),135,txt.y)
            doc.setFont(undefined, 'bold')    
            txt.y = Y+80
            line(txt.y)
            addLine(0.7)
            doc.text('Total Venc.',135,txt.y)
            doc.text('Total Desc.',180,txt.y)
            addLine(0.7)
            doc.text(parseFloat(func.horas.vale).toFixed(2),135,txt.y)
            doc.text('0',180,txt.y)
            addLine(0.7)
            doc.text('Total Liq. ->',135,txt.y)
            doc.text(viewMoneyBR(parseFloat(func.horas.vale).toFixed(2)),180,txt.y)
            addLine(0.7)
            line(txt.y)
            addLine(0.7)
            doc.text('Salario Base',10,txt.y)
            doc.text('SalContr.INSS',60,txt.y)
            doc.text('Base Calc. FGTS',90,txt.y)
            doc.text('FGTS do MES',120,txt.y)
            doc.text('Base Calc. IRRF',150,txt.y)
            doc.text('Faixa IRRF',180,txt.y)
            addLine(0.7)
            doc.text(viewMoneyBR(salario.valor.toFixed(2)),10,txt.y)
            doc.text('*****',65,txt.y)
            doc.text('*****',95,txt.y)
            doc.text('*****',125,txt.y)
            doc.text('*****',155,txt.y)
            doc.text('*****',185,txt.y)

            addLine(0.7)
            line(txt.y)
            addLine(0.7)

        }

        addLine(2)
        center_text('______________________________________________',[20,125])
        center_text('Assinatura',[20,125])    
        backLine(2)
        center_text('_______/_______/_______',[130,185])
        center_text('Data',[130,185])
        if(Y==5){
            addLine()
            line(txt.y)    
        }

        doc.setFont(undefined, 'normal')

    }

    let imp
    jsPDF.autoTableSetDefaults({
        headStyles: { fillColor: [37, 68, 65] },
    })

    doc = new jsPDF();

    clearTxt(37,10,[210,297])

    const params = new Object; 
        params.id = func.impostos.trim() == '' ? '0' : func.impostos
    const myPromisse = queryDB(params,'FIN-0');
    myPromisse.then((resolve)=>{
        
        imp = JSON.parse(resolve)

        if(tipo == 'holerite'){
            drawFrame()
            drawFrame(150)
            doc.addPage();
            txt.y = 46        
            drawFrame(5,'PGTO')
            drawFrame(150,'PGTO')
        }else if(tipo == 'VALE'){
            drawFrame(5,tipo)
            drawFrame(150,tipo)
        }else{
            drawFrame(5,'EMPRESTIMO')
            drawFrame(150,'EMPRESTIMO')
        }
            
//        doc.save('holerite.pdf')
        openPDF(doc,'holerite.pdf')
    })

}