document.addEventListener("turbo:load", function(){
  const dropdowns = document.querySelectorAll('.dropdown');
  
  dropdowns.forEach(dropdown => {
    const toggle = dropdown.querySelector('.dropdown-toggle');
    const menu = dropdown.querySelector('.dropdown-menu');
    
    // クリック時の処理
    toggle.addEventListener('click', function(e) {
      e.preventDefault();
      
      // 他のメニューを閉じる
      dropdowns.forEach(otherDropdown => {
        if (otherDropdown !== dropdown) {
          const otherMenu = otherDropdown.querySelector('.dropdown-menu');
          if (otherMenu) otherMenu.classList.remove('show');
        }
      });
      
      // 現在のメニューの表示切り替え
      if (menu) menu.classList.toggle('show');
    });
  });
  
  // 外側クリックで閉じる
  document.addEventListener('click', function(e) {
    if (!e.target.closest('.dropdown')) {
      dropdowns.forEach(dropdown => {
        const menu = dropdown.querySelector('.dropdown-menu');
        if (menu) menu.classList.remove('show');
      });
    }
  });
});