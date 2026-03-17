const { Sequelize } = require('sequelize');

const sequelize = new Sequelize('<DATABASE>', '<USERNAME>', '<PASSWORD>', {
    host: '<HOST>',
    dialect: 'mssql',
    define: {
        freezeTableName: true
    }
});

exports.sequelize = sequelize