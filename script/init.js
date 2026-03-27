const { Sequelize } = require('sequelize');

const sequelize = new Sequelize('<DATABASE>', '<USERNAME>', '<PASSWORD>', {
    host: '<HOST>',
    dialect: 'mssql',
    define: {
        freezeTableName: true
    },
    dialectOptions: {
        options: {
            encrypt: false,
            trustServerCertificate: true,
            // For connectivity on an IP address in some environments,
            // prevent the driver from enforcing an IP value in TLS servername.
            enableArithAbort: true
        }
    }
});

exports.sequelize = sequelize