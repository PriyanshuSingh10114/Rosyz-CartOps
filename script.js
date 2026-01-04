// HERO SLIDER 

var swiper = new Swiper('.heroSwiper', {
    slidesPerView: 1,
    loop: true,
    autoplay: true,
    effect: 'fade',
});

// CATEGORY SLIDER 

var swiper = new Swiper('.categorySwiper', {
    slidesPerView: 4,
    spaceBetween: 30,
    loop: true,
    autoplay: true,
    breakpoints:{
        1400:{
            slidesPerView: 4,
        },
        1200:{
            slidesPerView:3,
        },
        900:{
            slidesPerView: 2,
        },
        500:{
            slidesPerView: 1,
        },
    },
});

// OUR COLLECTIONS SLIDER 

var swiper = new Swiper('.collectionSwiper', {
    slidesPerView: 3,
    spaceBetween: 30,
    loop: true,
    autoplay: true,
    breakpoints:{
        1200:{
            slidesPerView:3,
        },
        900:{
            slidesPerView: 2,
        },
        500:{
            slidesPerView: 1,
        },
    },
});

// BLOGS SLIDER 

var swiper = new Swiper('.blogSwiper', {
    slidesPerView: 3,
    spaceBetween: 30,
    loop: true,
    autoplay: true,
    breakpoints:{
        1200:{
            slidesPerView:3,
        },
        900:{
            slidesPerView: 2,
        },
        500:{
            slidesPerView: 1,
        },
    },
});

// FOLLOW US SLIDER 

var swiper = new Swiper('.followSwiper', {
    slidesPerView: 5,
    spaceBetween: 10,
    loop: true,
    autoplay: true,
    breakpoints:{
        1200:{
            slidesPerView:5,
        },
        900:{
            slidesPerView: 3,
        },
        500:{
            slidesPerView: 1,
        },
    },
});

// MIXITUP FILTERS 
var mixer = mixitup('.product_cards');

const icons = document.querySelectorAll('#toggle_icon');

icons.forEach((icon, index) => {
    const smallProduct = document.querySelectorAll('.small_product')[index];
    icon.addEventListener('click', () => {
        const currentClass = icon.getAttribute('class');

        if (currentClass.includes('ri-add-large-line')) {
            icon.setAttribute('class', 'ri-subtract-line icon');
            smallProduct.classList.add('show_small_product');
        }
        else {
            icon.setAttribute('class', 'ri-add-large-line icon');
            smallProduct.classList.remove('show_small_product');
        }
    });
});

// SHOW MENU 

let bar = document.querySelector('.bars');
let menu = document.querySelector('.menu');

bar.addEventListener('click',()=>{
    menu.classList.toggle('show_menu');
}); 