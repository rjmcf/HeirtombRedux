$( document ).ready(function(){
    var toggler = document.getElementsByClassName("caret");

    for (let i = 0; i < toggler.length; i++) 
    {
        toggler[i].addEventListener("click", function() 
        {
            $(this).parent().parent().find(".nested").first().toggle(1000);
            this.classList.toggle("caret-down");
        });
    }
}); 