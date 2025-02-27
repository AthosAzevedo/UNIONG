const input = document.getElementById("barraDePesquisa");
const botaolupa = document.getElementById("lupa");

botaolupa.addEventListener("click", (evento)=>{
    evento.preventDefault();
    let filtro = barraPesquisa.value.toLowerCase();
    let cards = document.querySelectorAll(".card"); 
    
    cards.forEach(card => {
        let nomeAcao = card.querySelector(".NomeDaAcao").innerText.toLowerCase();

        if (nomeAcao.includes(filtro)) {
            card.style.display = "block";
        } else {
            card.style.display = "none";
        };
    }); 
    
    const inputbotao = document.getElementById("botaoInscrever");
    inputbotao.addEventListener("click",(evento)=>{
        evento.preventDefault();
        
    })
});