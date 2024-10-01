const images = [
    { original: 'https://cdn.starapps.studio/v2/apps/vsk/melobutter/groups/120096/flos-earrings-in-silver.media', compressed: 'https://cdn.starapps.studio/v2/apps/vsk/melobutter/groups/120096/flos-earrings-in-silver.media' },
    { original: 'https://cdn.starapps.studio/v2/apps/vsk/melobutter/groups/120096/flos-earrings-in-silver.media', compressed: 'https://cdn.starapps.studio/v2/apps/vsk/melobutter/groups/120096/flos-earrings-in-silver.media' },
    // Add all your image pairs here
];


function getValue(anchor) {
    const value = anchor.innerHTML 
    console.log(value);
    const part = value.split("/");
    const name= part[part.length - 1]
    console.log(name);
    

}

