// ЁРДАМЧИ ФУНКЦИЯЛАР - бутун тизим ишлаши учун
(function() {
    // Агар localStorage да users бўлмаса, яратамиз
    if (!localStorage.getItem('dd_users')) {
        localStorage.setItem('dd_users', JSON.stringify([]));
    }
    if (!localStorage.getItem('dd_ads')) {
        localStorage.setItem('dd_ads', JSON.stringify([
            {
                id: 1,
                title: 'Дала ишларига ишчи керак',
                price: '150',
                city: 'Душанбе',
                cat: 'Дала ишлари',
                author: 'Тожиддин',
                phone: '+992 93 123 45 67',
                date: '01.03.2026'
            },
            {
                id: 2,
                title: 'Қурилиш устаси',
                price: '500',
                city: 'Хуҷанд',
                cat: 'Қурилиш',
                author: 'Аҳмад',
                phone: '+992 92 111 22 33',
                date: '02.03.2026'
            }
        ]));
    }
   
    // Админ тез кириши учун
    window.demoUsers = [
        { phone: '+992 93 123 45 67', name: 'Тожиддин', pass: '123' },
        { phone: '+992 92 111 22 33', name: 'Аҳмад', pass: '123' }
    ];
})();

// localStorage дан маълумот олиш
function getUsers() { return JSON.parse(localStorage.getItem('dd_users') || '[]'); }
function getAds() { return JSON.parse(localStorage.getItem('dd_ads') || '[]'); }
function saveUsers(u) { localStorage.setItem('dd_users', JSON.stringify(u)); }
function saveAds(a) { localStorage.setItem('dd_ads', JSON.stringify(a)); }

// Блокланганлар
function getBlocked() { return JSON.parse(localStorage.getItem('dd_blocked') || '[]'); }

// Кириш
function quickLogin(phone) {
    let users = getUsers();
    let user = users.find(u => u.phone === phone);
    if (!user) {
        user = { name: 'Фойдаланувчи', phone: phone };
        users.push(user);
        saveUsers(users);
    }
    localStorage.setItem('dd_user', JSON.stringify(user));
    window.location.href = '/';
}
```
