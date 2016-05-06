class PermissionSwitch {
  constructor(user, domElement) {
    this.user = user;
    this.id = domElement.data().id;
    this.switchtype = domElement.data().switchtype;
    this.attribute = domElement.data().attribute;
    this.inputDomElement = domElement.find('input');
    this.checked = this.inputDomElement.prop('checked');
    this.disabled = this.inputDomElement.prop('disabled');
  }

  changeDisableSwitches(state) {
    $(`div[data-id=${this.id}][data-switchtype=last_only].permission-switch`).find('input').prop("checked", false);
    $(`div[data-id=${this.id}].disable`).find('input').prop("disabled", state);
  }
}

class LocalSwitch extends PermissionSwitch {
  constructor(user, domElement, permissions) {
    super(user, domElement);
    this.permission = _.find(permissions, _.matchesProperty('id', this.id));
    this.attributeState = this.permission[this.attribute];
  }

  toggleSwitch() {
    COPO.permissions.iconToggle(this.switchtype, this.id);
    if (this.switchtype === "disallowed") {
      this.changeDisableSwitches(this.checked);
    }
    this.permission[this.attribute] = this.nextState();
    $.ajax({
      url: `/users/${this.user}/devices/${this.permission['device_id']}/permissions/${this.id}`,
      type: 'PUT',
      dataType: 'script',
      data: { permission: this.permission }
    });
  }

  nextState() {
    if(this.attributeState === "disallowed") {
      return "complete"
    } else if(this.switchtype === "disallowed") {
      return "disallowed"
    } else if(this.attributeState === "complete") {
      return "last_only"
    } else if(this.attributeState === "last_only") {
      return "complete"
    } else {
      return !this.attributeState
    }
  }
}

class MasterSwitch extends PermissionSwitch {
  constructor(user, domElement, permissions, idType) {
    super(user, domElement);
    this.permissions = permissions.filter(_.matchesProperty(idType, this.id));
  }

  toggleSwitch() {
    this.permissions.forEach(function(permission) {
      const PDOMELEMENT = $(`div[data-id=${permission.id}][data-switchtype=${this.switchtype}].permission-switch`);
      const PSWITCH = new LocalSwitch(this.user, PDOMELEMENT, this.permissions);
      if ((PSWITCH.disabled && PSWITCH.switchtype === 'last_only')){
        this.inputDomElement.prop("checked", false)
      } else if (this.checked !== PSWITCH.checked) {
        PSWITCH.inputDomElement.prop("checked", this.checked);
        PSWITCH.checked = this.checked;
        PSWITCH.toggleSwitch();
      }
    }, this);
  }

  setState() {
    const SWITCHESCHECKED = [];

    this.permissions.forEach(function(permission){
      const PDOMELEMENT = $(`div[data-id=${permission.id}][data-switchtype=${this.switchtype}].permission-switch`);
      SWITCHESCHECKED.push(PDOMELEMENT.find('input').prop("checked"))
    }, this)
    const NEWMASTERCHECKEDSTATE = _.every(SWITCHESCHECKED)
    this.inputDomElement.prop("checked", NEWMASTERCHECKEDSTATE)

    if (this.switchtype === "disallowed") {
      $(`div[data-id=${this.id}][data-switchtype=last_only].master`).find('input').prop("checked", false);
      const MASTERS = $(`div[data-id=${this.id}].disable.master`).find('input');
      MASTERS.prop("disabled", NEWMASTERCHECKEDSTATE);
    }
  }
}
