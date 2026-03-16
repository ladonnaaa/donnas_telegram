const app = {
    telegrams:[],
    contacts:[],
    myCitizenId: null,
    currentOffice: null,
    offices: {},
    currentTab: 'inbox',
    currentSpread: 0,
    locales: {},

    init() {
        window.addEventListener('message', (event) => {
            const data = event.data;
            if (data.action === "openUI") {
                this.telegrams = data.telegrams ||[];
                this.contacts = data.contacts ||[];
                this.myCitizenId = data.myCitizenId;
                this.currentOffice = data.currentOffice;
                this.offices = data.offices || {};
                this.locales = data.locales || {};
                this.applyTranslations();
                this.setTab('inbox');
                this.resetBook();
                document.getElementById('app').style.display = 'flex';
                this.playSound('book_open.mp3');
            } else if (data.action === "closeUI") {
                document.getElementById('app').style.display = 'none';
                this.playSound('book_close.mp3');
            } else if (data.action === "updateData") {
                this.telegrams = data.telegrams || [];
                this.contacts = data.contacts || [];
                this.renderList();
            } else if (data.action === "playSound") {
                this.playSound(data.sound);
            }
        });

        document.getElementById('compose-form').addEventListener('submit', (e) => {
            e.preventDefault();
            this.sendTelegram();
        });

        document.getElementById('add-contact-form').addEventListener('submit', (e) => {
            e.preventDefault();
            this.addContact();
        });

        document.onkeydown = (data) => {
            if (data.which == 27) { this.closeUI(); }
        };
    },

    applyTranslations() {
        document.querySelectorAll('[data-loc]').forEach(el => {
            const key = el.getAttribute('data-loc');
            if (this.locales[key]) {
                el.innerHTML = this.locales[key];
            }
        });
    },

    resetBook() {
        this.currentSpread = 0;
        document.getElementById('sheet1').classList.remove('flipped');
        document.getElementById('sheet2').classList.remove('flipped');
        document.getElementById('sheet1').style.zIndex = 2;
        document.getElementById('sheet2').style.zIndex = 1;
        this.updateBookPosition();
    },

    flipNext() {
        if (this.currentSpread === 0) {
            this.playSound('page_flip.mp3');
            const s1 = document.getElementById('sheet1');
            s1.classList.add('flipped');
            setTimeout(() => { s1.style.zIndex = 1; }, 400);
            this.currentSpread = 1;
        } else if (this.currentSpread === 1) {
            this.playSound('page_flip.mp3');
            const s2 = document.getElementById('sheet2');
            s2.classList.add('flipped');
            setTimeout(() => { s2.style.zIndex = 2; }, 400);
            this.currentSpread = 2;
        }
        this.updateBookPosition();
    },

    flipPrev() {
        if (this.currentSpread === 2) {
            this.playSound('page_flip.mp3');
            const s2 = document.getElementById('sheet2');
            s2.classList.remove('flipped');
            setTimeout(() => { s2.style.zIndex = 1; }, 400);
            this.currentSpread = 1;
        } else if (this.currentSpread === 1) {
            this.playSound('page_flip.mp3');
            const s1 = document.getElementById('sheet1');
            s1.classList.remove('flipped');
            setTimeout(() => { s1.style.zIndex = 2; }, 400);
            this.currentSpread = 0;
        }
        this.updateBookPosition();
    },

    updateBookPosition() {
        const book = document.getElementById('book');
        if (this.currentSpread === 0) {
            book.style.transform = "translateX(0)";
        } else if (this.currentSpread === 1) {
            book.style.transform = "translateX(50%)";
        } else if (this.currentSpread === 2) {
            book.style.transform = "translateX(100%)";
        }
    },

    closeUI() {
        fetch(`https://${GetParentResourceName()}/close`, { method: 'POST', headers: {'Content-Type': 'application/json'} });
    },

    playSound(sound) {
        if (sound) {
            let audio = new Audio(`sounds/${sound}`);
            audio.volume = 0.5;
            audio.play().catch(e => console.log(e));
        }
    },

    triggerNotify(msgKey, type) {
        fetch(`https://${GetParentResourceName()}/clientNotify`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ message: this.locales[msgKey], type: type })
        }).catch(()=>{});
    },

    npcStampAnim() {
        fetch(`https://${GetParentResourceName()}/npcAction`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ action: 'stamp', officeId: this.currentOffice })
        }).catch(()=>{});
    },

    showView(viewId) {
        document.getElementById('read-view').style.display = 'none';
        document.getElementById('compose-view').style.display = 'none';
        document.getElementById('empty-view').style.display = 'none';
        document.getElementById('contacts-view').style.display = 'none';
        document.getElementById(viewId).style.display = 'block';
    },

    setTab(tab) {
        this.currentTab = tab;
        document.getElementById('tab-inbox').classList.remove('active-tab');
        document.getElementById('tab-outbox').classList.remove('active-tab');
        document.getElementById('tab-contacts').classList.remove('active-tab');
        document.getElementById(`tab-${tab}`).classList.add('active-tab');
        
        if(tab === 'contacts') {
            this.renderContacts();
        } else {
            this.renderList();
            this.showView('empty-view');
        }
    },

    formatDate(dateString) {
        try {
            return new Date(dateString).toLocaleDateString();
        } catch(e) {
            return dateString;
        }
    },

    renderList() {
        const container = document.getElementById('list-container');
        container.innerHTML = '';
        let list =[];
        if (this.currentTab === 'inbox') {
            list = this.telegrams.filter(t => t.receiver_citizenid === this.myCitizenId);
        } else if (this.currentTab === 'outbox') {
            list = this.telegrams.filter(t => t.sender_citizenid === this.myCitizenId);
        }
        list.forEach(t => {
            const div = document.createElement('div');
            div.className = `list-item ${t.is_read == 0 && this.currentTab === 'inbox' ? 'unread' : ''}`;
            const displayDate = this.formatDate(t.sent_time);
            div.innerHTML = `
                <div class="typewriter"><i class="fas fa-clock"></i> ${displayDate} | ${t.status}</div>
                <div class="handwriting" style="font-size: 24px;">To/From: ${this.currentTab === 'inbox' ? t.sender_name : t.receiver_citizenid}</div>
            `;
            div.onclick = () => {
                this.playSound('page_flip.mp3');
                this.viewTelegram(t);
            };
            container.appendChild(div);
        });
    },

    renderContacts() {
        const container = document.getElementById('list-container');
        container.innerHTML = '';
        this.showView('contacts-view');

        this.contacts.forEach(c => {
            const div = document.createElement('div');
            div.className = 'list-item';
            div.innerHTML = `
                <div class="handwriting" style="font-size: 26px;">${c.contact_name}</div>
                <div class="typewriter">ID: ${c.contact_citizenid}</div>
                <button class="delete-contact-btn"><i class="fas fa-times"></i></button>
            `;
            div.onclick = (e) => {
                if(e.target.closest('.delete-contact-btn')) {
                    this.deleteContact(c.id);
                } else {
                    this.composeTo(c.contact_citizenid);
                }
            };
            container.appendChild(div);
        });
    },

    composeTo(targetId) {
        this.playSound('pen_scratch.mp3');
        this.showView('compose-view');
        document.getElementById('compose-to').value = targetId;
    },

    addContact() {
        const name = document.getElementById('contact-name').value;
        const targetId = document.getElementById('contact-id').value;
        fetch(`https://${GetParentResourceName()}/addContact`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ name: name, targetId: targetId })
        }).then(() => {
            this.contacts.push({ id: Math.random(), contact_name: name, contact_citizenid: targetId });
            document.getElementById('add-contact-form').reset();
            this.renderContacts();
        }).catch(()=>{});
    },

    deleteContact(id) {
        fetch(`https://${GetParentResourceName()}/deleteContact`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ id: id })
        }).then(() => {
            this.contacts = this.contacts.filter(c => c.id !== id);
            this.renderContacts();
        }).catch(()=>{});
    },

    viewTelegram(t) {
        this.showView('read-view');
        document.getElementById('read-sender').innerHTML = `<i class="fas fa-feather-alt"></i> ${t.sender_name} <br><small style="font-family:'Special Elite'; font-size:12px;">Office: ${t.office_origin}</small>`;
        const displayDate = this.formatDate(t.sent_time);
        document.getElementById('read-status').innerText = `Status: ${t.status} | Sent: ${displayDate}`;
        document.getElementById('read-message').innerText = t.message;

        const deleteBtn = document.getElementById('delete-btn');
        if (t.sender_citizenid === this.myCitizenId) {
            deleteBtn.style.display = 'none';
        } else {
            deleteBtn.style.display = 'inline-block';
            deleteBtn.onclick = () => {
                this.playSound('page_flip.mp3');
                fetch(`https://${GetParentResourceName()}/deleteTelegram`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ id: t.id })
                }).then(() => {
                    this.telegrams = this.telegrams.filter(x => x.id !== t.id);
                    this.renderList();
                    this.showView('empty-view');
                }).catch(()=>{});
            };
        }

        if (t.is_read == 0 && this.currentTab === 'inbox') {
            fetch(`https://${GetParentResourceName()}/markRead`, { 
                method: 'POST', 
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ id: t.id }) 
            }).catch(()=>{});
            t.is_read = 1;
            this.renderList();
        }
    },

    setCompose() {
        this.playSound('pen_scratch.mp3');
        this.showView('compose-view');
    },

    showStamp(type) {
        const stamp = document.getElementById('stamp-overlay');
        stamp.innerText = this.locales[`ui_stamp_${type}`] || "DENIED";
        stamp.className = `stamp-overlay stamp-${type} stamp-show`;
        this.playSound('stamp_press.mp3');
        setTimeout(() => { stamp.classList.remove('stamp-show'); }, 3000);
    },

    refreshData() {
        fetch(`https://${GetParentResourceName()}/refreshData`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' }
        }).catch(()=>{});
    },

    sendTelegram() {
        const data = {
            receiver_citizenid: document.getElementById('compose-to').value,
            origin: this.currentOffice,
            message: document.getElementById('compose-message').value
        };
        fetch(`https://${GetParentResourceName()}/sendTelegramRequest`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(data)
        }).then(res => res.json()).then(resp => {
            
            this.npcStampAnim();

            if (resp.success) {
                this.playSound('coins.mp3');
                setTimeout(() => this.showStamp('approved'), 400);
                document.getElementById('compose-form').reset();
                
                setTimeout(() => {
                    this.refreshData();
                    this.setTab('outbox');
                }, 1500);

            } else {
                if (resp.status === "not_found") {
                    setTimeout(() => this.showStamp('not_found'), 400);
                    this.triggerNotify('notify_not_found', 'error');
                } else if (resp.status === "spam") {
                    setTimeout(() => this.showStamp('spam'), 400);
                    this.triggerNotify('notify_spam', 'error');
                } else {
                    setTimeout(() => this.showStamp('no_funds'), 400);
                    this.triggerNotify('notify_no_funds', 'error');
                }
            }
        }).catch(() => {
            this.npcStampAnim();
            setTimeout(() => this.showStamp('not_found'), 400);
        });
    }
};

window.onload = () => { app.init(); };