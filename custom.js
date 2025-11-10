function updateTunnel() {
    try {
        let gist = xover.session.gist;
        if (!gist) return;
        fetch(gist)
            .then(res => res.json())
            .then(gist => xover.session.server = gist["tunnel"])
    } catch (e) {
        console.error(e)
    }
}