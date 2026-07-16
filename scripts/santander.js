/* WORKSPACE */


export function setWorkspaces(name){

    const data = new URLSearchParams();        
    data.append("nome", name);
    const myRequest = new Request("backend/bank/set_workspace.php",{        
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

export function getWorkspaces(){
    const myRequest = new Request("backend/bank/get_workspaces.php",{
        method : "POST"
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

export function delWorkspaces(workspace_id){

    const data = new URLSearchParams();        
    data.append("id", workspace_id);
    const myRequest = new Request("backend/bank/del_workspace.php",{        
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

export function showWorkspaces(workspace_id){

    const data = new URLSearchParams();        
    data.append("id", workspace_id);
    const myRequest = new Request("backend/bank/show_workspace.php",{        
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

export function addWebhook(workspace_id,webhook){
    const data = new URLSearchParams();        
        data.append("workspace_id", workspace_id);
        data.append("webhook_url", webhook);
    const myRequest = new Request("backend/bank/add_webhook.php",{
        method : "POST",
        body : data
    });

    return new Promise((resolve,reject) =>{
        fetch(myRequest)
        .then(function (response){
            if (response.status === 200 || response.status === 201) { 
                resolve(response.text());                    
            } else { 
                reject(new Error("Houve algum erro na comunicação com o servidor"));                    
            } 
        });
    });   
}
