const app = document.getElementById('app');
const panel = document.getElementById('panel');
const dragHeader = document.getElementById('dragHeader');

const navButtons = document.querySelectorAll('.nav-btn');
const tabs = document.querySelectorAll('.tab');
const pageTitle = document.getElementById('pageTitle');

const giveItemBtn = document.getElementById('giveItemBtn');
const giveWeaponBtn = document.getElementById('giveWeaponBtn');
const spawnVehicleBtn = document.getElementById('spawnVehicleBtn');
const setJobBtn = document.getElementById('setJobBtn');
const setGangBtn = document.getElementById('setGangBtn');

const jobSelect = document.getElementById('jobName');
const jobGradeSelect = document.getElementById('jobGrade');

const gangSelect = document.getElementById('gangName');
const gangGradeSelect = document.getElementById('gangGrade');

const closeBtn = document.getElementById('closeBtn');

let cachedPlayers = [];
let cachedItems = [];
let cachedWeapons = [];
let cachedVehicles = [];
let cachedJobs = [];
let cachedGangs = [];

let selectedValues = {
    itemPlayer: '',
    item: '',
    weaponPlayer: '',
    weapon: '',
    vehicle: '',
    jobPlayer: '',
    gangPlayer: ''
};

let isDragging = false;
let dragOffsetX = 0;
let dragOffsetY = 0;

window.addEventListener('message', function (event) {
    const data = event.data;

    if (data.action === 'open') {
        applyConfig(data);
        app.classList.remove('hidden');
    }

    if (data.action === 'close') {
        app.classList.add('hidden');
    }
});

function applyConfig(data) {
    if (data.theme) {
        setTheme(data.theme);
    }

    cachedPlayers = Array.isArray(data.players) ? data.players : [];
    cachedItems = Array.isArray(data.items) ? data.items : [];
    cachedWeapons = Array.isArray(data.weapons) ? data.weapons : [];
    cachedVehicles = Array.isArray(data.vehicles) ? data.vehicles : [];
    cachedJobs = Array.isArray(data.jobs) ? data.jobs : [];
    cachedGangs = Array.isArray(data.gangs) ? data.gangs : [];

    setText('frameworkBadge', `Framework: ${data.framework || 'unknown'}`);

    setText('dataStats', `${cachedPlayers.length} Spieler · ${cachedItems.length} Items · ${cachedWeapons.length} Waffen`);
    setText('statPlayers', cachedPlayers.length);
    setText('statItems', cachedItems.length);
    setText('statWeapons', cachedWeapons.length);
    setText('statVehicles', cachedVehicles.length);
    setText('statJobs', cachedJobs.length);
    setText('statGangs', cachedGangs.length);

    if (data.ui) {
        setText('uiTitle', data.ui.Title);
        setText('uiSubtitle', data.ui.Subtitle);
        setText('footerText', data.ui.FooterText);

        if (data.ui.Sections) {
            applySection('items', data.ui.Sections.Items);
            applySection('weapons', data.ui.Sections.Weapons);
            applySection('vehicles', data.ui.Sections.Vehicles);
            applySection('jobs', data.ui.Sections.Jobs);
            applySection('gangs', data.ui.Sections.Gangs);
        }
    }

    if (data.labels) {
        setPlaceholder('itemPlayerId', data.labels.PlayerIdPlaceholder);
        setPlaceholder('weaponPlayerId', data.labels.PlayerIdPlaceholder);
        setPlaceholder('jobPlayerId', data.labels.PlayerIdPlaceholder);
        setPlaceholder('gangPlayerId', data.labels.PlayerIdPlaceholder);

        setPlaceholder('itemName', data.labels.ItemPlaceholder);
        setPlaceholder('itemAmount', data.labels.ItemAmountPlaceholder);

        setPlaceholder('weaponName', data.labels.WeaponPlaceholder);
        setPlaceholder('weaponAmmo', data.labels.AmmoPlaceholder);

        setPlaceholder('vehicleName', data.labels.VehiclePlaceholder);

        setText('giveItemBtn', data.labels.GiveItemButton);
        setText('giveWeaponBtn', data.labels.GiveWeaponButton);
        setText('spawnVehicleBtn', data.labels.SpawnVehicleButton);
        setText('setJobBtn', data.labels.SetJobButton);
        setText('setGangBtn', data.labels.SetGangButton);
    }

    renderPlayers(cachedPlayers);
    fillJobs(cachedJobs);
    fillGangs(cachedGangs);

    setupSearchSelects();
}

function setupSearchSelects() {
    setupSearchSelect('itemPlayer', 'itemPlayerId', cachedPlayers, {
        getMain: (entry) => `[${entry.id}] ${entry.name}`,
        getSub: (entry) => `ID ${entry.id}`,
        getValue: (entry) => String(entry.id)
    });

    setupSearchSelect('weaponPlayer', 'weaponPlayerId', cachedPlayers, {
        getMain: (entry) => `[${entry.id}] ${entry.name}`,
        getSub: (entry) => `ID ${entry.id}`,
        getValue: (entry) => String(entry.id)
    });

    setupSearchSelect('jobPlayer', 'jobPlayerId', cachedPlayers, {
        getMain: (entry) => `[${entry.id}] ${entry.name}`,
        getSub: (entry) => `ID ${entry.id}`,
        getValue: (entry) => String(entry.id)
    });

    setupSearchSelect('gangPlayer', 'gangPlayerId', cachedPlayers, {
        getMain: (entry) => `[${entry.id}] ${entry.name}`,
        getSub: (entry) => `ID ${entry.id}`,
        getValue: (entry) => String(entry.id)
    });

    setupSearchSelect('item', 'itemName', cachedItems, {
        getMain: (entry) => entry.label || entry.name,
        getSub: (entry) => entry.name,
        getValue: (entry) => entry.name
    });

    setupSearchSelect('weapon', 'weaponName', cachedWeapons, {
        getMain: (entry) => entry.label || entry.name,
        getSub: (entry) => entry.name,
        getValue: (entry) => entry.name
    });

    setupSearchSelect('vehicle', 'vehicleName', cachedVehicles, {
        getMain: (entry) => entry.label || entry.model,
        getSub: (entry) => entry.model,
        getValue: (entry) => entry.model
    });
}

function setupSearchSelect(selectName, inputId, entries, adapter) {
    const wrapper = document.querySelector(`[data-select="${selectName}"]`);
    const input = document.getElementById(inputId);

    if (!wrapper || !input) return;

    const results = wrapper.querySelector('.select-results');

    if (!results) return;

    input.onfocus = function () {
        openSearchResults(wrapper, results, entries, adapter, input, selectName);
    };

    input.oninput = function () {
        selectedValues[selectName] = '';
        openSearchResults(wrapper, results, entries, adapter, input, selectName);
    };

    input.onclick = function () {
        openSearchResults(wrapper, results, entries, adapter, input, selectName);
    };
}

function openSearchResults(wrapper, results, entries, adapter, input, selectName) {
    const query = String(input.value || '').toLowerCase().trim();

    let filtered = entries.filter((entry) => {
        const main = String(adapter.getMain(entry) || '').toLowerCase();
        const sub = String(adapter.getSub(entry) || '').toLowerCase();

        return main.includes(query) || sub.includes(query);
    });

    filtered = filtered.slice(0, 80);

    results.innerHTML = '';

    if (filtered.length === 0) {
        const empty = document.createElement('div');
        empty.className = 'select-empty';
        empty.textContent = 'Keine Ergebnisse gefunden';
        results.appendChild(empty);
    } else {
        filtered.forEach((entry) => {
            const option = document.createElement('div');
            option.className = 'select-option';

            const main = document.createElement('span');
            main.className = 'select-option-main';
            main.textContent = adapter.getMain(entry);

            const sub = document.createElement('span');
            sub.className = 'select-option-sub';
            sub.textContent = adapter.getSub(entry);

            option.appendChild(main);
            option.appendChild(sub);

            option.onclick = function () {
                const value = adapter.getValue(entry);
                selectedValues[selectName] = value;
                input.value = `${adapter.getMain(entry)} (${value})`;
                wrapper.classList.remove('open');
            };

            results.appendChild(option);
        });
    }

    wrapper.classList.add('open');
}

function getSelectedValue(selectName, inputId) {
    if (selectedValues[selectName]) {
        return selectedValues[selectName];
    }

    const input = document.getElementById(inputId);
    const raw = input ? String(input.value || '').trim() : '';

    const bracketMatch = raw.match(/\[(\d+)\]/);
    if (bracketMatch) return bracketMatch[1];

    const endParenMatch = raw.match(/\(([^)]+)\)$/);
    if (endParenMatch) return endParenMatch[1];

    const numberMatch = raw.match(/^\d+$/);
    if (numberMatch) return raw;

    return raw;
}

document.addEventListener('click', function (event) {
    document.querySelectorAll('.search-select').forEach((wrapper) => {
        if (!wrapper.contains(event.target)) {
            wrapper.classList.remove('open');
        }
    });
});

function setTheme(theme) {
    const root = document.documentElement;

    root.style.setProperty('--primary-color', theme.PrimaryColor);
    root.style.setProperty('--secondary-color', theme.SecondaryColor);
    root.style.setProperty('--background-dark', theme.BackgroundDark);
    root.style.setProperty('--background-warm', theme.BackgroundWarm);
    root.style.setProperty('--card-background', theme.CardBackground);
    root.style.setProperty('--card-border', theme.CardBorder);
    root.style.setProperty('--text-color', theme.TextColor);
    root.style.setProperty('--muted-text-color', theme.MutedTextColor);
    root.style.setProperty('--overlay-background', theme.OverlayBackground);
    root.style.setProperty('--border-radius', theme.BorderRadius);
    root.style.setProperty('--card-radius', theme.CardRadius);
}

function applySection(prefix, section) {
    const sectionElement = document.getElementById(`${prefix}Section`);
    const navButton = document.querySelector(`[data-tab="${prefix}"]`);

    if (!sectionElement || !section) return;

    if (section.Enabled === false) {
        sectionElement.classList.add('hidden');

        if (navButton) {
            navButton.classList.add('hidden');
        }

        return;
    }

    sectionElement.classList.remove('hidden');

    if (navButton) {
        navButton.classList.remove('hidden');
    }

    setText(`${prefix}Title`, section.Title);
    setText(`${prefix}Description`, section.Description);
}

function fillJobs(jobs) {
    cachedJobs = Array.isArray(jobs) ? jobs : [];

    jobSelect.innerHTML = '<option value="">Job auswählen</option>';
    jobGradeSelect.innerHTML = '<option value="">Rang auswählen</option>';

    cachedJobs.forEach((job) => {
        const option = document.createElement('option');

        option.value = job.name;
        option.textContent = `${job.label} (${job.name})`;

        jobSelect.appendChild(option);
    });
}

function fillJobGrades(jobName) {
    jobGradeSelect.innerHTML = '<option value="">Rang auswählen</option>';

    const job = cachedJobs.find((entry) => entry.name === jobName);

    if (!job || !Array.isArray(job.grades)) return;

    job.grades.forEach((grade) => {
        const option = document.createElement('option');

        option.value = grade.grade;
        option.textContent = `${grade.grade} - ${grade.label}`;

        jobGradeSelect.appendChild(option);
    });
}

function fillGangs(gangs) {
    cachedGangs = Array.isArray(gangs) ? gangs : [];

    gangSelect.innerHTML = '<option value="">Gang auswählen</option>';
    gangGradeSelect.innerHTML = '<option value="">Rang auswählen</option>';

    cachedGangs.forEach((gang) => {
        const option = document.createElement('option');

        option.value = gang.name;
        option.textContent = `${gang.label} (${gang.name})`;

        gangSelect.appendChild(option);
    });
}

function fillGangGrades(gangName) {
    gangGradeSelect.innerHTML = '<option value="">Rang auswählen</option>';

    const gang = cachedGangs.find((entry) => entry.name === gangName);

    if (!gang || !Array.isArray(gang.grades)) return;

    gang.grades.forEach((grade) => {
        const option = document.createElement('option');

        option.value = grade.grade;
        option.textContent = `${grade.grade} - ${grade.label}`;

        gangGradeSelect.appendChild(option);
    });
}

function renderPlayers(players) {
    const playerPreview = document.getElementById('playerPreview');

    if (!playerPreview) return;

    playerPreview.innerHTML = '';

    if (!Array.isArray(players) || players.length === 0) {
        const div = document.createElement('div');
        div.className = 'player-pill';
        div.textContent = 'Keine Spieler gefunden';
        playerPreview.appendChild(div);
        return;
    }

    players.slice(0, 12).forEach((player) => {
        const div = document.createElement('div');
        div.className = 'player-pill';
        div.textContent = `[${player.id}] ${player.name}`;
        playerPreview.appendChild(div);
    });
}

function setText(id, value) {
    const element = document.getElementById(id);

    if (!element || value === undefined || value === null) return;

    element.textContent = value;
}

function setPlaceholder(id, value) {
    const element = document.getElementById(id);

    if (!element || value === undefined || value === null) return;

    element.placeholder = value;
}

function nuiPost(name, data = {}) {
    fetch(`https://${GetParentResourceName()}/${name}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify(data),
    });
}

closeBtn.addEventListener('click', function () {
    nuiPost('close');
});

navButtons.forEach((button) => {
    button.addEventListener('click', function () {
        const tab = button.dataset.tab;

        navButtons.forEach((btn) => btn.classList.remove('active'));
        tabs.forEach((tabElement) => tabElement.classList.remove('active'));

        button.classList.add('active');

        const target = document.getElementById(`tab-${tab}`);

        if (target) {
            target.classList.add('active');
        }

        pageTitle.textContent = button.textContent;
    });
});

giveItemBtn.addEventListener('click', function () {
    nuiPost('giveItem', {
        playerId: getSelectedValue('itemPlayer', 'itemPlayerId'),
        itemName: getSelectedValue('item', 'itemName'),
        amount: document.getElementById('itemAmount').value
    });
});

giveWeaponBtn.addEventListener('click', function () {
    nuiPost('giveWeapon', {
        playerId: getSelectedValue('weaponPlayer', 'weaponPlayerId'),
        weaponName: getSelectedValue('weapon', 'weaponName'),
        ammo: document.getElementById('weaponAmmo').value
    });
});

spawnVehicleBtn.addEventListener('click', function () {
    nuiPost('spawnVehicle', {
        vehicleName: getSelectedValue('vehicle', 'vehicleName')
    });
});

setJobBtn.addEventListener('click', function () {
    nuiPost('setJob', {
        playerId: getSelectedValue('jobPlayer', 'jobPlayerId'),
        jobName: document.getElementById('jobName').value,
        grade: document.getElementById('jobGrade').value
    });
});

setGangBtn.addEventListener('click', function () {
    nuiPost('setGang', {
        playerId: getSelectedValue('gangPlayer', 'gangPlayerId'),
        gangName: document.getElementById('gangName').value,
        grade: document.getElementById('gangGrade').value
    });
});

jobSelect.addEventListener('change', function () {
    fillJobGrades(jobSelect.value);
});

gangSelect.addEventListener('change', function () {
    fillGangGrades(gangSelect.value);
});

document.addEventListener('keydown', function (event) {
    if (event.key === 'Delete') {
        nuiPost('close');
    }
});

dragHeader.addEventListener('mousedown', function (event) {
    isDragging = true;

    const rect = panel.getBoundingClientRect();

    dragOffsetX = event.clientX - rect.left;
    dragOffsetY = event.clientY - rect.top;
});

document.addEventListener('mousemove', function (event) {
    if (!isDragging) return;

    const newLeft = event.clientX - dragOffsetX;
    const newTop = event.clientY - dragOffsetY;

    panel.style.left = `${Math.max(0, newLeft)}px`;
    panel.style.top = `${Math.max(0, newTop)}px`;
});

document.addEventListener('mouseup', function () {
    isDragging = false;
});